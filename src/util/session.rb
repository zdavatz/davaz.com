#!/usr/bin/env ruby
# Util::Session -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'sbsm/session'
require 'util/lookandfeel'
require 'state/states'

module DAVAZ
	module Util	
		class Session < SBSM::Session
			SERVER_NAME = DAVAZ.config.server_name 
			DEFAULT_STATE = State::Personal::Init 
			DEFAULT_ZONE = :personal
			DEFAULT_LANGUAGE = 'en'
			PERSISTENT_COOKIE_NAME = 'davaz.com-preferences'
			LOOKANDFEEL = DAVAZ::Util::Lookandfeel
			def initialize(*args)
				super
				#@state.extend(State::Admin::Admin)
			end
			def active_state
        if(state_id = @valid_input[:state_id])
          @attended_states[state_id]
				elsif(zone != @zone)
					@active_state.switch_zone(zone)
        end || @active_state
			end
			def cap_max_states
				# ignore
			end
			def foot_navigation
				@active_state.foot_navigation
			end
			def login
				# @app.login raises Yus::YusError
				@user = @app.login(user_input(:email), user_input(:pass))
			end
			def logout
				@app.logout(@user)
				super
			end
			def top_navigation
				@active_state.top_navigation
			end
		end
	end
end
