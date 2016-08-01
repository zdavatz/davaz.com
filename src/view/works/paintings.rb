require 'view/template'
require 'view/works/init'

module DaVaz::View
  module Works
    class PaintingsComposite < Init; end

    class Paintings < PaintingsTemplate
      CONTENT = PaintingsComposite
    end

    class AdminPaintings < AdminPaintingsTemplate
      CONTENT = PaintingsComposite
    end
  end
end
