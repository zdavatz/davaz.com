require 'htmlgrid/divcomposite'
require 'htmlgrid/dojotoolkit'

module DAVAZ::View
  class OneLiner < HtmlGrid::Component
    CSS_ID = 'oneliner'

    def to_html(context)
      return '' unless model
      args = {
        'colors'        => [],
        'messageString' => ''
      }
      messages = []
      model.each { |oneliner|
        oneliner.text.split("\r\n").each { |line|
          args['colors'].push(oneliner.color_in_hex)
          messages.push(line.gsub('\'', '\\\'').strip)
        }
      }
      args['messageString'] = "'#{messages.join('|')}'"
      dojo_args = {
        'data-dojo-props' => args.map { |k, v|
          v = "[#{v.map { |s| "'#{s}'"}.join(',')}]" if v.is_a?(Array)
          "#{k}:#{v}"
        }.join(',')
      }
      dojo_tag('ywesee.widget.OneLiner', dojo_args).to_html(context)
    end
  end
end
