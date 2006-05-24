#!/usr/bin/env ruby
# State::Communication::Global -- davaz.com -- 06.09.2005 -- mhuggler@ywesee.com

require 'state/global'
require 'state/communication/guestbook'
require 'state/communication/guestbookentry'
require 'state/communication/links'
require 'state/communication/news'
require 'state/communication/shop'

module DAVAZ
	module State
		module Communication
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :communication
	GLOBAL_MAP = {
		:guestbook						=>	State::Communication::Guestbook,
		:guestbookentry				=>	State::Communication::GuestbookEntry,
		:links								=>	State::Communication::Links,
		:news									=>	State::Communication::News,
		:send_order						=>	State::Communication::Shop,
		:shop_thanks					=>	State::Communication::ShopThanks,
		:shop									=>	State::Communication::Shop,
		:ajax_shop						=>	State::Communication::AjaxShop,
	}
	def init
		@session[:cart_items] ||= []
	end
end
		end
	end
end
