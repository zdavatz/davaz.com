#!/usr/bin/env ruby
# State::Redirect -- davaz.com -- 04.09.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/redirect'

module DAVAZ
	module State
		class Redirect < State::Global
			VIEW = View::Redirect
		end
	end
end
