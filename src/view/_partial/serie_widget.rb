require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'
require 'ext/htmlgrid/component'

module DaVaz::View
  class SerieWidget < HtmlGrid::NamedComponent
    def to_html(context)
      props = {
        'transitionInterval' => 1500,
        'delay'              => 3500,
        'imageHeight'        => DaVaz.config.show_image_height,
        'dataUrl'            => @lookandfeel.event_url(
          @session.zone, :ajax_images)
      }.update(@model)
      props.delete('images') # titles don't parse cleanly in dojo so we
      props.delete('titles') # pass images and titles by json
      dojo_tag("ywesee.widget.#{@name}", {
        'data-dojo-props' => dojo_props(props)
      }).to_html(context)
    end
  end
end
