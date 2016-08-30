require 'json'
require 'htmlgrid/component'

module DaVaz::View
  # Represents json response
  class Ajax < HtmlGrid::Component
    HTTP_HEADERS = {
      'Content-Type' => 'application/json;charset=UTF-8'
    }

    def to_html(context)
      @model.to_json
    end
  end

  # Represents text(html) response
  class AjaxText < HtmlGrid::Component
    HTTP_HEADERS = {
      'Content-Type' => 'text/html;charset=UTF-8'
    }

    def to_html(context)
      @model
    end
  end
end
