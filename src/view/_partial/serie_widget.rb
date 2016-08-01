require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'

module DaVaz
  module View
    class SerieWidget < HtmlGrid::NamedComponent
      def compose_args
        {
          'transitionInterval' => '1500',
          'delay'              => '3500',
          'imageHeight'        => DaVaz.config.show_image_height,
          'dataUrl'            => @lookandfeel.event_url(
            @session.zone, :ajax_images),
        }
      end

      def to_html(context)
        args = compose_args.update(@model)
        args.delete('images') # titles don't parse cleanly in dojo so we
        args.delete('titles') # pass images and titles by json
        dojo_args = {
          'data-dojo-props' => args.map { |k, v|
            v = "'#{v}'" if v.is_a?(String)
            v = "[#{v.map { |s| "'#{s}'"}.join(',')}]" if v.is_a?(Array)
            "#{k}:#{v}"
          }.join(',')
        }
        dojo_tag("ywesee.widget.#@name", dojo_args).to_html(context)
      end
    end
  end
end
