require 'state/global'
require 'view/works/init'

module DaVaz::State
  module Works
    class Init < Global
      VIEW = DaVaz::View::Works::Init

      def init
        @model = OpenStruct.new
        @model.movies   = @session.app.load_movies_ticker
        @model.oneliner = @session.app.load_oneliner('index')
      end
    end
  end
end
