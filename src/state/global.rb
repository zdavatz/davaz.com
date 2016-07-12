#!/usr/bin/env ruby
# State::Global -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'sbsm/state'
require 'htmlgrid/link'
require 'state/admin/login'
require 'state/ajax_response'
require 'state/art_object'
require 'state/communication/global'
require 'state/communication/shop'
require 'state/gallery/global'
require 'state/personal/init' 
require 'state/personal/global' 
require 'state/tooltip'
require 'state/works/global'

module DAVAZ
	module State
		class Global < SBSM::State
			include Admin::LoginMethods
			attr_reader :model
			attr_accessor :switched_zone
			GLOBAL_MAP = {
				:art_object						=>	State::ArtObject,
				:ajax_movie_gallery		=>	State::Works::AjaxMovieGallery,
				#:ajax_desk						=>	State::Gallery::AjaxDesk,
				#:ajax_desk_artobject	=>	State::Gallery::AjaxDeskArtobject,
				:ajax_rack						=>	State::Gallery::AjaxRack,
				:home									=>	State::Personal::Init,
				:login_form						=>	State::Admin::AjaxLoginForm,
				:shop_art_object			=>	State::Communication::ShopArtObject,
			}	
			HOME_STATE = State::Personal::Init
			VIEW = View::Personal::Init
			def ajax_desk
				if(@session.user_input(:artobject_id))
					State::Gallery::AjaxDeskArtobject.new(@session, [])
				else
					State::Gallery::AjaxDesk.new(@session, [])
				end
			end
      def ajax_images
        if @model.respond_to?(:show_items)
          AjaxResponse.new(@session, @model.show_items)
        elsif @model.respond_to?(:serie_items)
          AjaxResponse.new(@session, @model.serie_items)
        else
          AjaxResponse.new(@session, @model)
        end
      end
			def tooltip
				State::Tooltip.new(@session, @model)
			end
			def error_check_and_store(key, value, mandatory=[])
				if(value.is_a? RuntimeError)
					@errors.store(key, value)
				elsif(mandatory.include?(key) && mandatory_violation(value))
					error = create_error('e_missing_fields', key, value)
					@errors.store(key, error)
				end
			end
			def foot_navigation
				[
					:login_form,
					[	:communication, :guestbook ],
					[	:communication, :shop ],
					:email_link,
					[	:communication, :news ],
					[	:communication, :links ],
					[	:personal, :home ],
				]
			end
			def search_result
				artgroup_id = @session.user_input(:artgroup_id)
				query = @session.user_input(:search_query)
				model = OpenStruct.new
				model.result = @session.app.search_artobjects(query, artgroup_id)
				model.artgroups = @session.app.load_artgroups 
				model
			end
			def search
				model = search_result
				State::Gallery::Result.new(@session, model)
			end
			def switch_zone(zone)
				name = zone.to_s.split('_').collect { |word| 
					word.capitalize }.join
				newstate = State.const_get(name).const_get('Global').new(@session, @model)
				newstate.unset_previous
				newstate.switched_zone = true
				newstate.previous = self
				newstate
			rescue NameError
				self
			end
			def top_navigation
				[
					[	:personal, :life ],
					[	:personal, :work ],
					[	:personal, :inspiration ],
					[	:personal, :family ],
				]
			end
			def trigger(event)
				newstate = super
				if(@switched_zone)
					newstate.unset_previous
					newstate.previous = @previous
				end
				newstate
			end
=begin
				klass = case zone
								when :personal
									State::Personal::Global
								end
				if(klass)
					klass.new(@session, @model)
				else
					self
				end
			end
			def user_input(keys=[], mandatory=[])
				keys = [keys] unless keys.is_a?(Array)
				mandatory = [mandatory] unless mandatory.is_a?(Array)
				if(hash = @session.user_input(*keys))
					unless(hash.is_a?(Hash))
						hash = {keys.first => hash}
					end
					hash.each { |key, value| 
						carryval = nil
						if (value.is_a? RuntimeError)
							carryval = value.value
							@errors.store(key, hash.delete(key))
						elsif (mandatory.include?(key) && mandatory_violation(value))
							error = create_error('e_missing_' << key.to_s, key, value)
							@errors.store(key, error)
							hash.delete(key)
						else
							carryval = value
						end
					}
					hash
				else
					{}
				end
			end
=end
		end
	end
end
