#!/usr/bin/env ruby
# State::Public::Global -- davaz.com -- 29.08.2005 -- mhuggler@ywesee.com

require 'state/global'
require 'state/public/articles'
require 'state/public/exhibitions'
require 'state/public/lectures'

module DaVaz
	module State
		module Public 
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :public
	EVENT_MAP = {
		:ajax_article					=>	State::Public::AjaxArticle,
		:articles							=>	State::Public::Articles,
		:exhibitions					=>	State::Public::Exhibitions,
		:lectures							=>	State::Public::Lectures,
	}
end
		end
	end
end
