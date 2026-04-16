require 'net/http'
require 'json'
require 'uri'

module DaVaz
  module Util
    module YoutubeHelper
      CACHE_TTL = 3600 # 1 hour

      @cache = {}
      @cache_timestamps = {}

      # Mapping of clip IDs to their source video IDs (for thumbnails).
      # Loaded lazily from json/clips.json.
      def self.clip_source_videos
        candidates = []
        if defined?(DaVaz) && DaVaz.respond_to?(:config) && DaVaz.config.respond_to?(:project_root)
          candidates << File.join(DaVaz.config.project_root, 'json', 'clips.json')
        end
        candidates << File.join(File.expand_path('../../..', __FILE__), 'json', 'clips.json')
        candidates << File.join(Dir.pwd, 'json', 'clips.json')
        clips_json = candidates.find { |f| File.exist?(f) }
        unless clips_json
          warn "YoutubeHelper: clips.json not found in #{candidates.inspect}" unless @clip_source_videos
          return @clip_source_videos ||= {}
        end
        mtime = File.mtime(clips_json)
        return @clip_source_videos if @clip_source_videos && @clip_source_videos_mtime == mtime
        data = JSON.parse(File.read(clips_json, encoding: 'utf-8'))
        @clip_source_videos = data.each_with_object({}) do |clip, h|
          h[clip['clip_id']] = clip['source_video_id'] if clip['clip_id'] && clip['source_video_id']
        end
        @clip_source_videos_mtime = mtime
        @clip_source_videos
      rescue StandardError => e
        warn "YoutubeHelper: failed to load clips.json: #{e.message}"
        @clip_source_videos ||= {}
      end

      def self.extract_video_id(url)
        return nil if url.nil? || url.empty?
        if url =~ %r{(?:youtube\.com/watch\?.*v=|youtu\.be/|youtube\.com/embed/)([A-Za-z0-9_-]{11})}
          $1
        elsif url =~ %r{youtube\.com/clip/([A-Za-z0-9_-]+)}
          # For clip URLs, return the source video ID for thumbnail use
          clip_source_videos[$1]
        end
      end

      def self.clip_url?(url)
        return false if url.nil? || url.empty?
        url =~ %r{youtube\.com/clip/}
      end

      # Returns a thumbnail variant for clips that share a source video,
      # so they don't all show the same image. First clip gets hqdefault,
      # subsequent clips get hq1, hq2, hq3 (different frames, full size).
      CLIP_THUMB_VARIANTS = %w[maxresdefault hq1 hq2 hq3].freeze

      def self.clip_thumb_index(clip_id)
        source_vid = clip_source_videos[clip_id]
        return 0 unless source_vid
        siblings = clip_source_videos.select { |_, v| v == source_vid }.keys.sort
        idx = siblings.index(clip_id) || 0
        idx % CLIP_THUMB_VARIANTS.length
      end

      def self.clip_thumbnail_url(url)
        return nil unless clip_url?(url)
        clip_id = url[%r{youtube\.com/clip/([A-Za-z0-9_-]+)}, 1]
        return nil unless clip_id
        source_vid = clip_source_videos[clip_id]
        return nil unless source_vid
        variant = CLIP_THUMB_VARIANTS[clip_thumb_index(clip_id)]
        "https://img.youtube.com/vi/#{source_vid}/#{variant}.jpg"
      end

      def self.api_keys
        keys = []
        # Read keys from .yt-keys file (one key per line)
        # Check project root first, then home directory
        [File.join(DaVaz.config.project_root, '.yt-keys'),
         File.expand_path('~/.yt-keys')].each do |yt_keys_file|
          next unless File.exist?(yt_keys_file)
          File.readlines(yt_keys_file).each do |line|
            key = line.strip
            keys << key unless key.empty? || key.start_with?('#')
          end
        end
        # Also check environment variables as fallback
        keys << ENV['YOUTUBE_API_KEY'] if ENV['YOUTUBE_API_KEY'] && !ENV['YOUTUBE_API_KEY'].empty?
        (2..10).each do |i|
          key = ENV["YOUTUBE_API_KEY_#{i}"]
          keys << key if key && !key.empty?
        end
        keys.uniq
      end

      def self.prefetch_view_counts(art_objects)
        video_ids = art_objects.map { |ao|
          extract_video_id(ao.url)
        }.compact.uniq
        fetch_view_counts(video_ids) if video_ids.any?
      end

      def self.fetch_view_counts(video_ids)
        keys = api_keys
        return {} if keys.empty? || video_ids.empty?

        now = Time.now
        uncached = video_ids.reject { |id|
          @cache_timestamps[id] && (now - @cache_timestamps[id]) < CACHE_TTL
        }

        if uncached.any?
          # Query each API key — different keys may have different videos
          keys.each do |api_key|
            # Only query IDs we haven't found yet
            missing = uncached.reject { |id| @cache[id] && @cache_timestamps[id] == now }
            break if missing.empty?

            begin
              missing.each_slice(50) do |batch|
                ids_param = batch.join(',')
                uri = URI("https://www.googleapis.com/youtube/v3/videos?part=statistics&id=#{ids_param}&key=#{api_key}")
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                http.open_timeout = 5
                http.read_timeout = 5
                response = http.get(uri.request_uri)
                data = JSON.parse(response.body)
                if data['items']
                  data['items'].each do |item|
                    id = item['id']
                    views = item.dig('statistics', 'viewCount')
                    @cache[id] = views ? views.to_i : nil
                    @cache_timestamps[id] = now
                  end
                end
              end
            rescue StandardError => e
              warn "YoutubeHelper (key ...#{api_key[-4..]}): #{e.message}"
            end
          end
        end

        video_ids.each_with_object({}) { |id, h| h[id] = @cache[id] }
      end

      def self.fetch_view_count(video_id)
        return nil unless video_id
        result = fetch_view_counts([video_id])
        result[video_id]
      end

      def self.cached_view_count(video_id)
        return nil unless video_id
        @cache[video_id]
      end

      def self.format_view_count(count)
        return nil unless count
        if count >= 1_000_000
          "#{(count / 1_000_000.0).round(1)}M views"
        elsif count >= 1_000
          "#{(count / 1_000.0).round(1)}K views"
        else
          "#{count} views"
        end
      end
    end
  end
end
