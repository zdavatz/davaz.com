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

      def self.fetch_view_counts(video_ids)
        api_key = ENV['YOUTUBE_API_KEY']
        return {} if api_key.nil? || api_key.empty? || video_ids.empty?

        now = Time.now
        uncached = video_ids.reject { |id|
          @cache_timestamps[id] && (now - @cache_timestamps[id]) < CACHE_TTL
        }

        if uncached.any?
          begin
            # API supports up to 50 IDs per request
            uncached.each_slice(50) do |batch|
              ids_param = batch.join(',')
              uri = URI("https://www.googleapis.com/youtube/v3/videos?part=statistics&id=#{ids_param}&key=#{api_key}")
              response = Net::HTTP.get(uri)
              data = JSON.parse(response)
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
            warn "YoutubeHelper: #{e.message}"
          end
        end

        video_ids.each_with_object({}) { |id, h| h[id] = @cache[id] }
      end

      def self.fetch_view_count(video_id)
        return nil unless video_id
        result = fetch_view_counts([video_id])
        result[video_id]
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
