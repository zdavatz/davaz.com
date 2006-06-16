#!/usr/bin/env ruby
# Util::Session -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'sbsm/session'
require 'util/lookandfeel'
require 'state/states'

module DAVAZ
	module Util	
		class Session < SBSM::Session
			SERVER_NAME = 'www.davaz.com'
			DEFAULT_STATE = State::Personal::Init 
			DEFAULT_ZONE = :personal
			DEFAULT_LANGUAGE = 'en'
			PERSISTENT_COOKIE_NAME = 'davaz.com-preferences'
			LOOKANDFEEL = DAVAZ::Util::Lookandfeel
			def active_state
				active = super
				if(zone == @zone)
					active
				else
					active.switch_zone(zone)
				end
			end
			def cap_max_states
				# ignore
			end
			def foot_navigation
				@active_state.foot_navigation
			end
			def login
				if(user = @app.login(user_input(:email), user_input(:pass)))
					@user = user
				end
			end
			def top_navigation
				@active_state.top_navigation
			end
		end
	end
end
