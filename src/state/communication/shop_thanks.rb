#!/usr/bin/env ruby
# State::Communication::ShopThanks -- davaz.com -- 04.10.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/shop_thanks'

module DAVAZ
	module State
		module Communication
class ShopThanks < State::Communication::Global
	VIEW = View::Communication::ShopThanks
end
		end
	end
end
