require 'net/http'
require 'json'
require 'uri'

module DaVaz
  module Util
    module YoutubeHelper
      CACHE_TTL = 3600 # 1 hour

      @cache = {}
      @cache_timestamps = {}

      def self.extract_video_id(url)
        return nil if url.nil? || url.empty?
        if url =~ %r{(?:youtube\.com/watch\?.*v=|youtu\.be/|youtube\.com/embed/)([A-Za-z0-9_-]{11})}
          $1
        end
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
