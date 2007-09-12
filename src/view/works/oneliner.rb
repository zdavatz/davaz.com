#!/usr/bin/env ruby
# View::OneLiner -- davaz.com -- 24.08.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/dojotoolkit'

module DAVAZ
	module View
		module Works
class OneLiner < HtmlGrid::Component
	CSS_ID = 'oneliner'
	def to_html(context)
		args = {
			'messages'	=> [],
			'colors'		=> [],
		}
		model.each { |oneliner|
			oneliner.text.split("\r\n").each { |line|
				args['colors'].push(oneliner.color_in_hex)
				args['messages'].push(line)
			}
		}
		dojo_tag('ywesee.widget.OneLiner', args).to_html(context)
	end
end
		end
	end
end
