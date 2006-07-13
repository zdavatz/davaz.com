#!/usr/bin/env ruby
# Validator -- davaz.com -- 19.07.2005 -- mhuggler@ywesee.com

require 'sbsm/validator'
require 'cgi'

module DAVAZ
	module Util
		class Validator < SBSM::Validator
			DATES = [
				:date,
			]
			EVENTS = [ 
				:add_entry,
				:ajax_add_element,
				:ajax_add_form,
				:ajax_add_link,
				:ajax_all_tags,
				:ajax_all_tags_link,
				:ajax_article,
				:ajax_check_removal_status,
				:ajax_delete_image,
				:ajax_delete_link,
				:ajax_desk,
				:ajax_desk_artobject,
				:ajax_home,
				:ajax_image_browser,
				:ajax_reload_tag_images,
				:ajax_movie_gallery,
				:ajax_multiples,
				:ajax_rack,
				:ajax_remove_element,
				:ajax_shop,
				:ajax_upload_image,
				:ajax_upload_image_form,
				:article,
				:articles,
				:art_object,
				:back,
				:bottleneck,
				:data_url,
				:design,
				:drawings,
				:edit,
				:exhibitions,
				:family,
				:gallery,
				:guestbook,
				:guestbookentry,
				:home,
				:images,
				:inspiration,
				:lectures,
				:life,
				:links,
				:login,
				:multiples,
				:new,
				:news,
				:paintings,
				:personal_life,
				:photos,
				:poems, 
				:remove_all_items,
				:schnitzenthesen,
				:search,
				:send_order,
				:shop_thanks,
				:shop,
				:shopitem,
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
				:country_id,
				#:email,
				:image_title,
				:messagetxt,
				:lang,
				:language,
				:link_word,
				:location,
				:material_id,
				:model,
				:name,
				:object_type,
				:search_query,
				:select_name,
				:selected_id,
				:serie_id,
				:size,
				:street,
				:surname,
				:table,
				:tags,
				:target,
				:text,
				:title,
				:tool_id,
				:url,
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
