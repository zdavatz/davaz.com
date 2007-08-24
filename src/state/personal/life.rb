#!/usr/bin/env ruby
# State::Personal::Life -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/life'

module DAVAZ
	module State
		module Personal
class Life < State::Personal::Global
	VIEW = View::Personal::Life
	DIRECT_EVENT = :life
	def init
		@model = OpenStruct.new
		lang = @session.user_input(:lang) || 'English'
    @model.biography_items = @session.app.load_hislife(lang) 
		add_slideshow_items(@model, 'hislife_show')
		@model.oneliner = @session.app.load_oneliner('hislife')
		@model.serie_id = @session.app.load_serie_id("Site His Life %s" % lang)
	end
end
class AjaxAddNewBioElement < State::Admin::AjaxAddNewElement 
	def init
    lang = @session.user_input(:lang) || "English"
		values = {
      :title    =>  @session.lookandfeel.lookup(:click2edit), 
			:serie_id =>	@model.serie_id,
			:text			=>	@session.lookandfeel.lookup(:click2edit_textarea), 
		}		
		insert_id = @session.app.insert_artobject(values)
		@model = @session.app.load_artobject(insert_id)
    puts @model.inspect
	end
end
class AdminLife < State::Personal::Life
	VIEW = View::Personal::AdminLife
  def ajax_add_new_element
    AjaxAddNewBioElement.new(@session, @model)
  end
end
		end
	end
end
