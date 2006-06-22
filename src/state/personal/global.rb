#!/usr/bin/env ruby
# State::Personal::Global -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'state/global'
require 'state/personal/init'
require 'state/personal/life'
require 'state/personal/work'
require 'state/personal/inspiration'
require 'state/personal/family'
require 'state/personal/thefamily'
require 'state/public/global'
require 'ostruct'

module DAVAZ
	module State
		module Personal 
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :personal
	EVENT_MAP = {
		:home									=>	State::Personal::Init,
		:family								=>	State::Personal::Family,
		:inspiration					=>	State::Personal::Inspiration,
		:life									=>	State::Personal::Life,
		:the_family						=>	State::Personal::TheFamily,
		:work									=>	State::Personal::Work,
	}
	def add_slideshow_items(ostruct, name)
		ostruct.slideshow_items = {
			'images'	=>	[],
			'titles'	=>	[],
		}
		slideshow_items = @session.app.load_slideshow(name)
		slideshow_items.each { |item|
			image = DAVAZ::Util::ImageHelper.image_path(item.display_id, 'slideshow')
			ostruct.slideshow_items['images'].push(image)
			ostruct.slideshow_items['titles'].push(item.title)
		}
		ostruct
	end
end
		end
	end
end
