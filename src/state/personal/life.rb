#!/usr/bin/env ruby
# State::Personal::Life -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/life'

module DAVAZ
	module State
		module Personal
class Life < State::Personal::Global
	VIEW = View::Personal::Life
	def init
		@model = OpenStruct.new
		if(lang = @session.user_input(:lang))
			@model.biography_items = @session.app.load_biography_text("life_#{lang}") 
		else
			@model.biography_items = @session.app.load_biography_text("life_english") 
		end
		@model.slideshow_items = {
			'images'	=>	[],
			'titles'	=>	[],
		}
		slideshow_items = @session.app.load_slideshow('life')
		slideshow_items.each { |item|
			image = DAVAZ::Util::ImageHelper.image_path(item.display_id, 'slideshow')
			@model.slideshow_items['images'].push(image)
			@model.slideshow_items['titles'].push(item.title)
		}
		@model.oneliner = @session.app.load_oneliner('hislife')
		super
	end
end
class AdminLife < State::Personal::Global
	VIEW = View::Personal::AdminLife
	def init
		@model = OpenStruct.new
		if(lang = @session.user_input(:lang))
			@model.biography_items = @session.app.load_biography_text("life_#{lang}") 
		else
			@model.biography_items = @session.app.load_biography_text("life_english") 
		end
		add_slideshow_items(@model, 'life')
		super
	end
end
		end
	end
end
