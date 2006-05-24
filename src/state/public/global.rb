#!/usr/bin/env ruby
# State::Public::Global -- davaz.com -- 29.08.2005 -- mhuggler@ywesee.com

require 'state/global'
require 'state/public/gallery_search'
require 'state/public/articles'
require 'state/public/exhibitions'
require 'state/public/lectures'

module DAVAZ
	module State
		module Public 
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :public
	GLOBAL_MAP = {
		:ajax_article					=>	State::Public::AjaxArticle,
		:articles							=>	State::Public::Articles,
		:exhibitions					=>	State::Public::Exhibitions,
		:gallery_search				=>	State::Public::GallerySearch,
		:lectures							=>	State::Public::Lectures,
	}
end
		end
	end
end
