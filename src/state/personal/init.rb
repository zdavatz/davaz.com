require 'state/global'
require 'view/personal/init'

module DaVaz::State
  module Personal 
    class Init < Global
      VIEW = DaVaz::View::Personal::Init

      def init
        @model = OpenStruct.new
        @model.movies   = @session.app.load_movies_ticker
        @model.oneliner = @session.app.load_oneliner_by_location('index')
        all_videos = @session.app.load_youtube_video_ids
        @model.video_movies = all_videos.select { |v| v.artgroup_id == 'MOV' }.shuffle
        @model.video_shorts = all_videos.select { |v| v.artgroup_id == 'SHO' }.shuffle
        @model.video_clips  = all_videos.select { |v| v.artgroup_id == 'CLI' }.shuffle
      end
    end
  end
end
