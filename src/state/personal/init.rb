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
        @model.video_thumbnails = @session.app.load_youtube_video_ids.shuffle
      end
    end
  end
end
