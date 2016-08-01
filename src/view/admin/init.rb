require 'htmlgrid/divcomposite'
require 'view/template'

module DaVaz::View
  module Admin
    class InitComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => 'successfull_login'
      }
    end

    class Init < Template
      CONTENT = InitComposite
    end
  end
end
