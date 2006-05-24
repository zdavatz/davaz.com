#!/usr/bin/env ruby
# Model::OneLiner-- davaz.com -- 23.08.2005 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class OneLiner
			attr_accessor :oneliner_id, :text, :location, :color, :size, :active
			COLORS = {
				'black'			=>	'#000000',
				'blue'			=>	'#0000ff',
				'cyan'			=>	'#00ffff',
				'darkGray'	=>	'#404040',
				'gray'			=>	'#808080',
				'green'			=>	'#00ff00',
				'lightGray'	=>	'#c0c0c0',
				'magenta'		=>	'#ff00ff',
				'orange'		=>	'#ffc800',
				'pink'			=>	'#ffafaf',
				'red'				=>	'#ff0000',
				'white'			=>	'#ffffff',
				'yellow'		=>	'#ffff00',
			}
			def color_in_hex
				self.class::COLORS[@color]
			end
		end
	end
end
