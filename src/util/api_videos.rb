require 'json'
require 'net/http'
require 'rack/utils'
require 'set'
require 'uri'
require 'util/db_manager'
require 'util/youtube_helper'

module DaVaz
  module Util
    # Rack middleware that exposes a small JSON API for adding YouTube
    # videos to the artobjects table without going through the SBSM/HTML
    # layer.
    #
    #   POST /api/videos
    #   Authorization: Bearer <token>
    #   Content-Type: application/json
    #
    #   { "url": "https://www.youtube.com/watch?v=...",
    #     "tag_color": "yellow"|"purple"|"red"  (optional)
    #   }
    #
    # Tokens live one-per-line in etc/api_tokens (lines starting with `#`
    # are comments). The middleware fetches title/duration/description
    # from the YouTube Data API, classifies by duration (CLI / SHO / MOV),
    # inserts via DbManager#insert_artobject, and optionally appends a
    # promoted tag to json/promoted_tags.json.
    #
    # If no tag_color is given in the body, the description text is
    # sniffed for a leading color word — "yellow", "purple", or "red"
    # as the first whole word (or the entire description). This keeps
    # working with the convention of putting the color name in the video
    # description on YouTube.
    class ApiVideos
      API_PATH = '/api/videos'.freeze

      # Duration thresholds match the rule documented in CLAUDE.md for
      # individual additions: <=80s CLI, 81-240s SHO, >=241s MOV.
      CLI_MAX = 80
      SHO_MAX = 240

      # Mapping of tag-color names to the JSON bucket they populate.
      # Add a new color here + a sibling array in json/promoted_tags.json
      # + matching CSS to extend.
      TAG_COLOR_BUCKETS = {
        'yellow' => 'promoted',
        'purple' => 'promoted_violet',
        'red'    => 'promoted_red',
      }.freeze

      def initialize(app, db_manager: nil, tokens_file: nil, tags_file: nil)
        @app = app
        @db_manager = db_manager
        @tokens_file = tokens_file || File.join(
          DaVaz.config.project_root, 'etc', 'api_tokens')
        @tags_file = tags_file || File.join(
          DaVaz.config.project_root, 'json', 'promoted_tags.json')
      end

      def call(env)
        return @app.call(env) unless api_request?(env)
        return method_not_allowed unless env['REQUEST_METHOD'] == 'POST'
        return unauthorized unless authorized?(env)
        handle_post(env)
      rescue StandardError => e
        SBSM.warn "ApiVideos: #{e.class}: #{e.message}" if defined?(SBSM)
        json_response(500, error: 'internal error')
      end

      private

      def api_request?(env)
        path = env['PATH_INFO'].to_s
        path == API_PATH || path == "#{API_PATH}/"
      end

      def authorized?(env)
        header = env['HTTP_AUTHORIZATION'].to_s
        return false unless header.start_with?('Bearer ')
        presented = header.sub(/\ABearer\s+/, '').strip
        return false if presented.empty?
        valid_tokens.any? { |t| Rack::Utils.secure_compare(t, presented) }
      end

      def valid_tokens
        return [] unless File.exist?(@tokens_file)
        File.readlines(@tokens_file).map { |l| l.strip }
            .reject { |l| l.empty? || l.start_with?('#') }
      end

      def handle_post(env)
        body = read_body(env)
        return json_response(400, error: 'invalid JSON') unless body.is_a?(Hash)
        url = body['url'].to_s.strip
        return json_response(422, error: 'missing url') if url.empty?
        video_id = YoutubeHelper.extract_video_id(url)
        return json_response(422, error: 'unrecognized YouTube URL') unless video_id
        return json_response(409, error: 'already exists', id: existing_id(video_id)) if existing_id(video_id)

        meta = fetch_metadata(video_id)
        return json_response(502, error: 'YouTube API failed') unless meta
        return json_response(404, error: 'video not found on YouTube') if meta == :not_found

        title = (body['title'].to_s.empty? ? meta[:title] : body['title']).then { |t| strip_emojis(t) }
        text  = body['text'].to_s.empty? ? meta[:description] : body['text']
        text  = strip_emojis(text)
        artgroup = classify(meta[:seconds])
        date = meta[:published_on]

        id = insert(artgroup: artgroup, title: title, text: text, url: url, date: date)
        return json_response(500, error: 'insert failed') unless id

        tag_color = body['tag_color'].to_s.downcase
        tag_color = sniff_tag_color(text) unless TAG_COLOR_BUCKETS.key?(tag_color)
        tag_added = nil
        if TAG_COLOR_BUCKETS.key?(tag_color)
          tag_added = append_promoted_tag(title, tag_color)
        end

        json_response(201,
          id: id,
          artgroup_id: artgroup,
          title: title,
          url: url,
          duration_seconds: meta[:seconds],
          tag_added: tag_added)
      end

      def read_body(env)
        raw = env['rack.input']&.read.to_s
        env['rack.input']&.rewind
        return nil if raw.empty?
        JSON.parse(raw)
      rescue JSON::ParserError
        nil
      end

      def existing_id(video_id)
        db.send(:connection) do |conn|
          rows = conn.query(
            "SELECT artobject_id FROM artobjects " \
            "WHERE url LIKE '%#{conn.escape(video_id)}%' LIMIT 1").to_a
          return rows.first['artobject_id'] if rows.any?
        end
        nil
      end

      def fetch_metadata(video_id)
        keys = YoutubeHelper.api_keys
        return nil if keys.empty?
        keys.each do |key|
          uri = URI("https://www.googleapis.com/youtube/v3/videos" \
                    "?part=snippet,contentDetails&id=#{video_id}&key=#{key}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.open_timeout = 5
          http.read_timeout = 5
          res = http.get(uri.request_uri)
          next unless res.is_a?(Net::HTTPSuccess)
          data = JSON.parse(res.body)
          items = data['items'] || []
          return :not_found if items.empty?
          item = items.first
          return {
            title: item.dig('snippet', 'title').to_s,
            description: item.dig('snippet', 'description').to_s,
            seconds: parse_iso8601_duration(item.dig('contentDetails', 'duration').to_s),
            published_on: item.dig('snippet', 'publishedAt').to_s[0, 10]
          }
        end
        nil
      end

      def parse_iso8601_duration(iso)
        return 0 unless iso =~ /\APT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?\z/
        $1.to_i * 3600 + $2.to_i * 60 + $3.to_i
      end

      def classify(seconds)
        return 'CLI' if seconds <= CLI_MAX
        return 'SHO' if seconds <= SHO_MAX
        'MOV'
      end

      # Strips emojis and other characters outside the BMP for MySQL utf8
      # (3-byte) compatibility — same convention as the rebuild script.
      def strip_emojis(str)
        str.to_s.each_char.select { |c| c.ord <= 0xFFFF }.join
      end

      def insert(artgroup:, title:, text:, url:, date:)
        values = {
          artgroup_id:    artgroup,
          tool_id:        '0',
          material_id:    '0',
          country_id:     '',
          date:           date.empty? ? Time.now.strftime('%Y-%m-%d') : date,
          size:           '',
          location:       '',
          language:       '',
          title:          title,
          serie_id:       'AAA',
          serie_position: '',
          public:         '1',
          movie_type:     'none',
          text:           text,
          url:            url,
          author:         '',
        }
        db.insert_artobject(values)
      end

      # Picks a tag color from the description text if it starts with
      # (or is just) one of the recognized color words. Conservative
      # match — only the first whole word counts, so descriptions like
      # "Red things" don't accidentally classify as red.
      def sniff_tag_color(text)
        return nil if text.nil?
        first = text.to_s.strip.downcase[/\A[a-z]+/]
        TAG_COLOR_BUCKETS.key?(first) ? first : nil
      end

      def append_promoted_tag(title, color)
        return nil unless File.exist?(@tags_file)
        bucket = TAG_COLOR_BUCKETS[color]
        return nil unless bucket
        data = JSON.parse(File.read(@tags_file, encoding: 'utf-8'))
        data[bucket] ||= []
        entry = [title, title.downcase]
        return nil if data[bucket].any? { |label, _| label == title }
        data[bucket] << entry
        File.write(@tags_file, JSON.pretty_generate(data) + "\n")
        { bucket: bucket, label: title }
      end

      def db
        @db_manager ||= DaVaz::Util::DbManager.new
      end

      def json_response(status, payload)
        body = JSON.generate(payload)
        [status, { 'content-type' => 'application/json', 'content-length' => body.bytesize.to_s }, [body]]
      end

      def method_not_allowed
        json_response(405, error: 'method not allowed')
      end

      def unauthorized
        [401,
         { 'content-type' => 'application/json',
           'www-authenticate' => 'Bearer realm="api"' },
         [JSON.generate(error: 'unauthorized')]]
      end
    end
  end
end
