#!/usr/bin/env ruby
# View::Communication::ShopThanks -- davaz.com -- 04.10.2005 -- mhuggler@ywesee.com

require 'view/template'
require 'htmlgrid/divcomposite'

module DaVaz
	module View
		module Communication
class ShopThanksComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	'shop_thanks',
	}
end
class ShopThanks < View::CommunicationTemplate
	CONTENT = ShopThanksComposite
end
		end
	end
end
