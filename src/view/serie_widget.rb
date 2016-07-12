require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'

module DAVAZ
  module View
    class SerieWidget < HtmlGrid::NamedComponent
      def compose_args
        {
          'transitionInterval' => '1500',
          'delay'              => '3500',
          'imageHeight'        => DAVAZ.config.show_image_height,
          'id'                 => @name.to_s,
          'dataUrl'            => @lookandfeel.event_url(
            @session.zone, :ajax_images),
        }
      end

      def to_html(context)
        args = compose_args.update(@model)
        args.delete("images") # titles don't parse cleanly in dojo so we
        args.delete("titles") # pass images and titles by json
        dojo_tag("ywesee.widget.#@name", compose_args).to_html(context)
      end
    end
  end
end
