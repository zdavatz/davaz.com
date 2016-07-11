require 'view/publictemplate'
require 'view/works/works'

module DAVAZ
  module View
    module Works
      class DrawingsComposite < View::Works::Works; end

      class Drawings < View::DrawingsPublicTemplate
        CONTENT = View::Works::DrawingsComposite
      end

      class AdminDrawings < View::AdminDrawingsPublicTemplate
        CONTENT = View::Works::DrawingsComposite
      end
    end
  end
end
