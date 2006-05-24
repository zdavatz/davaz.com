#!/usr/bin/env ruby
# View::ToolTip::Article -- davaz.com -- 27.03.2006 -- mhuggler@ywesee.com

require 'view/tooltip/tooltip'

module DAVAZ
	module View
		module ToolTip
class ArticleComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:text,
		[0,1]	=>	:read_on,
	}
	def read_on(model)
		link = HtmlGrid::Link.new(model.display_id, @model, @session)
		link.href = @lookandfeel.event_url(:article, :article, model.display_id)
		link.value = @lookandfeel.lookup(:read_on)
		link
	end
end
class Article < View::ToolTip::ToolTip 
	COMPONENTS = {
		[0,01]	=>	ArticleComposite,
	}
end
		end
	end
end
