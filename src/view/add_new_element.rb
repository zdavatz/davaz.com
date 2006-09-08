#!/usr/bin/env ruby
# View::AddNewElement -- davaz.com -- 05.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/textarea'

module DAVAZ
	module View
		class AddNewElementComposite < HtmlGrid::DivComposite
			CSS_ID = "add-new-element-composite"
			COMPONENTS = {
				[0,1]	=>	:add_new_element_link,
			}
			CSS_ID_MAP = {
				2	=>	'add-new-element-form'
			}
			def add_new_element_link(model)
				link = HtmlGrid::Link.new(:new_element, model, @session, self)
				link.href = 'javascript:void(0)'
				url = @lookandfeel.event_url(@session.zone, :ajax_add_new_element)
				script = "addNewElement('#{url}')"
				link.set_attribute('onclick', script)
				link
			end
		end
	end
end
