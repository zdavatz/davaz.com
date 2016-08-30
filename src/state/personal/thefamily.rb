require 'state/personal/global'
require 'view/personal/thefamily'

module DaVaz::State
  module Personal
    class TheFamily < Global
      VIEW = DaVaz::View::Personal::TheFamily

      def init
        @model = @session.app.load_thefamily_text
      end
    end
  end
end
