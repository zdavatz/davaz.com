#!/usr/bin/env ruby
# State::Personal::Global -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'state/global'
require 'state/personal/init'
require 'state/personal/life'
require 'state/personal/work'
require 'state/personal/inspiration'
require 'state/personal/family'
require 'state/personal/thefamily'
require 'state/public/global'

module DAVAZ
	module State
		module Personal 
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :personal
	GLOBAL_MAP = {
		:home									=>	State::Personal::Init,
		:family								=>	State::Personal::Family,
		:inspiration					=>	State::Personal::Inspiration,
		:life									=>	State::Personal::Life,
		:the_family						=>	State::Personal::TheFamily,
		:work									=>	State::Personal::Work,
	}
end
		end
	end
end
