require 'htmlgrid/component'

module DaVaz::View
  class Redirect < HtmlGrid::Component
    def http_headers
      {
        'Status'   => '303 See Other',
        'Location' => @model,
      }
    end
  end
end
