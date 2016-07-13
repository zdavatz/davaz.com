require 'json'
require 'htmlgrid/component'
require 'htmlgrid/span'

module DAVAZ
  module View
    class AjaxResponse < HtmlGrid::Component

      def to_html(context)
        @model.to_json
      end
    end

    class AjaxHtmlResponse < HtmlGrid::Component

      def to_html(context)
        @model
      end
    end
  end
end
