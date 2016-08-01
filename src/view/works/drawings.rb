require 'view/template'
require 'view/works/init'

module DaVaz::View
  module Works
    class DrawingsComposite < Init; end

    class Drawings < DrawingsTemplate
      CONTENT = DrawingsComposite
    end

    # @api admin
    class AdminDrawings < AdminDrawingsTemplate
      CONTENT = DrawingsComposite
    end
  end
end
