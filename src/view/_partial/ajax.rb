require 'json'
require 'htmlgrid/component'

module DaVaz::View
  # Represents json response
  class Ajax < HtmlGrid::Component
    def to_html(context)
      @model.to_json
    end
  end

  # Represents text(html) response
  class AjaxText < HtmlGrid::Component
    def to_html(context)
      @model
    end
  end
end
