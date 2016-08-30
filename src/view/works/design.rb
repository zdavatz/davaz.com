require 'view/template'
require 'view/works/init'

module DaVaz::View
  module Works
    class DesignComposite < Init; end

    class Design < DesignTemplate
      CONTENT = DesignComposite
    end

    class AdminDesign < AdminDesignTemplate
      CONTENT = DesignComposite
    end
  end
end
