#!/usr/bin/env ruby
# State::Personal::Work -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/work'
require 'state/admin/ajax_states'

module DAVAZ
	module State
		module Personal
class Work < State::Personal::Global
	VIEW = View::Personal::Work
	def init
		@model = OpenStruct.new
		@model.text = @session.app.load_hiswork_text
		@model.slideshow = @session.app.load_tag_artobjects('Morphopolis')
		@model.oneliner = @session.app.load_oneliner('hiswork')
	end
end
class AjaxAddNewElement < State::Admin::AjaxAddNewElement 
	def init
		values = {
			:text			=>	@session.lookandfeel.lookup(:click2edit), 
		}		
		insert_id = @session.app.insert_artobject(values)
		@model = @session.app.load_artobject(insert_id)
	end
end
class AdminWork < State::Personal::Work
	VIEW = View::Personal::AdminWork
	def ajax_add_new_element
		AjaxAddNewElement.new(@session, @model)
	end
end
		end
	end
end
