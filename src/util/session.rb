#!/usr/bin/env ruby
# Util::Session -- davaz.com -- 29.07.2013 -- yasaka@ywesee.com
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
				if(DAVAZ.config.autologin)
					#autologin to be removed, only for debugging purposes
					@state.extend(State::Admin::Admin)
				end
			end
      def flavor
        # davaz.com does not use flavor
        nil
      end
			def active_state
        @active_state = super
        unless @token_login_attempted
          @token_login_attempted = true
          if user = login_token
            # allow autologin via token
            @active_state.extend(State::Admin::Admin)
            if @active_state.respond_to?(:autologin)
              @active_state = @active_state.autologin(user)
            end
          end
        end
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
				@user = @app.login(user_input(:login_email), user_input(:login_password))
        if @user.valid? && user_input(:remember_me)
          set_cookie_input :remember, @user.generate_token
          set_cookie_input :name,     @user.name || user_input(:login_email)
        else
          @cookie_input.delete :remember
        end
        @user
			end
      def login_token
        # @app.login_token raises Yus::YusError
        name  = (persistent_user_input(:name) || get_cookie_input(:name))
        token = (persistent_user_input(:remember) || get_cookie_input(:remember))
        if name && token && !token.empty? && \
           (!@user.respond_to?(:valid?) || !@user.valid?)
          @user = @app.login_token(name, token)
          if @user.valid?
            set_cookie_input :remember, @user.generate_token
            @user
          else
            nil
          end
        else
          nil
        end
      rescue Yus::YusError
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
