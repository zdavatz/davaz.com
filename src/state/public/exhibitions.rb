require 'state/public/global'
require 'view/public/exhibitions'

module DaVaz::State
  module Public
    class Exhibitions < Global
      VIEW = DaVaz::View::Public::Exhibitions

      def init
        @model = @session.load_exhibitions
      end
    end

    class AdminExhibitions < Exhibitions
      VIEW = DaVaz::View::Public::AdminExhibitions
    end
  end
end
