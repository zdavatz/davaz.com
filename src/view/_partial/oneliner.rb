require 'htmlgrid/divcomposite'
require 'htmlgrid/dojotoolkit'
require 'ext/htmlgrid/component'

module DaVaz::View
  class Oneliner < HtmlGrid::Component
    CSS_ID = 'oneliner'

    def to_html(context)
      return '' unless model
      props = {
        'colors'        => [],
        'messageString' => ''
      }
      messages = []
      model.each { |oneliner|
        oneliner.text.split(/(\r?\n)|\<br\s\/\>/).each { |line|
          props['colors'].push(oneliner.color_in_hex)
          messages.push(line.gsub('\'', '\\\'').strip)
        }
      }
      props['messageString'] = messages.join('|')
      dojo_tag('ywesee.widget.oneliner', {
        'data-dojo-props' => dojo_props(props)
      }).to_html(context)
    end
  end
end
