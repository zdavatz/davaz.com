require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'
require 'ext/htmlgrid/component'

module DaVaz
  module View
    class Ticker < HtmlGrid::Component
      attr_accessor :component_width, :component_height

      def init
        @component_width  = DaVaz.config.ticker_component_width
        @component_height = DaVaz.config.ticker_component_height
        super
      end

      def to_html(context)
        props = { # as html attributes
          'images'          => [],
          'eventUrls'       => [],
          'componentWidth'  => @component_width.to_i,
          'componentHeight' => @component_height.to_i,
          'widgetId'        => 'ticker',
          'stopped'         => 'true',
        }
        (model || []).each { |item|
          if item.artobject_id
            if Util::ImageHelper.has_image?(item.artobject_id)
              path = Util::ImageHelper.image_url(item.artobject_id, 'medium')
              props['images'].push(path)
              unless item.url.nil? || item.url.empty?
                event_url = item.url
              else
                event_url = @lookandfeel.event_url(:gallery, :art_object, [
                  ['artgroup_id' , item.artgroup_id],
                  ['artobject_id', item.artobject_id]
                ])
              end
              props['eventUrls'].push(event_url)
            end
          end
        }
        dojo_tag('ywesee.widget.ticker', {
          'data-dojo-props' => dojo_props(props)
        }).to_html(context)
      end
    end

    class InnerTicker < HtmlGrid::Div
      def init
        super
        @value = View::Ticker.new(@model, @session, self)
        @value.component_height = 135
        @value.component_width  = 180
      end
    end

    class TickerContainer < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :ticker,
      }
      CSS_ID_MAP    = ['ticker_container']
      CSS_STYLE_MAP = ['display: none']

      def ticker(model)
        tick = Ticker.new(model, @session, self)
        tick.component_height = 135
        tick.component_width  = 180
        tick
      end
    end
  end
end
