#!/usr/bin/env ruby
# Validator -- davaz.com -- 19.07.2005 -- mhuggler@ywesee.com

require 'sbsm/validator'
require 'cgi'

module DAVAZ
	module Util
		class Validator < SBSM::Validator
      ALLOWED_TAGS = %{a b br div font h1 h2 h3 i img li ol p pre strong u ul
                       embed object param}
			DATES = [
				:date,
				:date_ch,
			]
			EVENTS = [ 
				:ajax_add_element,
				:ajax_add_form,
				:ajax_add_link,
				:ajax_add_new_element,
				:ajax_all_tags,
				:ajax_all_tags_link,
				:ajax_article,
				:ajax_cancel_live_edit,
				:ajax_check_removal_status,
				:ajax_delete_element,
				:ajax_delete_guest,
				:ajax_delete_image,
				:ajax_delete_link,
				:ajax_desk,
				:ajax_desk_artobject,
				:ajax_guestbookentry,
				:ajax_home,
				:ajax_images,
				:ajax_image_action,
				#:ajax_image_browser,
				:ajax_reload_tag_images,
				:ajax_live_edit_form,
				:ajax_movie_gallery,
				:ajax_multiples,
				:ajax_rack,
				:ajax_remove_element,
				:ajax_save_live_edit,
				:ajax_save_gb_live_edit,
				:ajax_shop,
				:ajax_upload_image,
				:ajax_upload_image_form,
				:article,
				:articles,
				:art_object,
				:back,
				:bottleneck,
				:data_url,
				:delete,
				:design,
				:drawings,
				:edit,
				:exhibitions,
				:family,
				:flush_ajax_errors,
				:gallery,
				:guestbook,
				:home,
				:inspiration,
				:lectures,
				:life,
				:links,
				:login,
				:login_form,
				:logout,
				:multiples,
				:new,
				:new_art_object,
				:news,
				:paintings,
				:personal_life,
				:photos,
				:poems, 
				:remove_all_items,
				:schnitzenthesen,
				:search,
				:send_order,
				:shop,
				:shop_art_object,
				:shop_thanks,
				:shopitem,
				:submit_entry,
				:the_family,
				:tooltip,
				:update,
				:upload_image,
				:movies,
				:work,
			]
			FILES = [
				:image_file,
			]
      HTML = [ :text, :update_value, ]
			ZONES = [ 
				:admin,
				:communication,
				:gallery, 
				:personal, 
				:public, 
				:poems,
				:stream,
				:tooltip,
				:works, 
			]
			STRINGS = [
				:address,
				:artgroup_id,
				:author,
				:breadcrumbs,
				:city,
				:charset,
				:country,
				:country_id,
				:event,
				:form_artgroup_id,
				:form_language,
				:fragment,
				:guest_id,
				:image_title,
				:fields,
				:field_key,
				:lang,
				:language,
				:link_word,
				:location,
				:login_email,
				:login_password,
				:material_id,
				:messagetxt,
				:name,
				:node_id,
				:object_type,
				:old_serie_id,
				:price,
				:search_query,
				:select_name,
				:select_value,
				:selected_id,
				:serie_id,
				:serie_position,
				:size,
				:street,
				:surname,
				:table,
				:tags,
				:tags_to_s,
				:target,
				:title,
				:tool_id,
				:url,
        :wordpress_url,
			]
			NUMERIC = [
				:artobject_id,
				:count,
				:link_id,
				:parent_link_id,
				:postal_code,
			]
			def serie_id(value)
				if(/[A-Z]/.match(value))
					value
				else
					raise SBSM::InvalidDataError.new(:e_invalid_zone_id, :dose, value)
				end
			end
			def show(value)
				value
			end
			def zone(value)
				if(value.to_s.empty?)
					raise SBSM::InvalidDataError.new("e_invalid_zone", :zone, value)
				end
				zone = value.to_s.intern
				if(self::class::ZONES.include?(zone))
					zone
				else
					raise SBSM::InvalidDataError.new("e_invalid_zone", :zone, value)
				end
			end
		end
	end
end
