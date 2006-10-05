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
		artobjects = @session.app.load_tag_artobjects(name)
		artobjects.each { |artobject|
			image = DAVAZ::Util::ImageHelper.image_url(artobject.artobject_id, 'slideshow')
			@model.slideshow_items['images'].push(image)
			@model.slideshow_items['titles'].push(artobject.title)
		}
		ostruct
	end
end
		end
	end
end
