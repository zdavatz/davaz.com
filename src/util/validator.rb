#!/usr/bin/env ruby
# Validator -- davaz.com -- 19.07.2005 -- mhuggler@ywesee.com

require 'sbsm/validator'
require 'cgi'

module DAVAZ
	module Util
		class Validator < SBSM::Validator
			EVENTS = [ 
				:add_entry,
				:ajax_add_image,
				:ajax_article,
				:ajax_desk,
				:ajax_desk_artobject,
				:ajax_home,
				:ajax_movie_gallery,
				:ajax_remove_image,
				:ajax_rack,
				:ajax_shop,
				:article,
				:articles,
				:artobject,
				:back,
				:bottleneck,
				:data_url,
				:design,
				:drawings,
				:exhibitions,
				:family,
				:gallery,
				:guestbook,
				:guestbookentry,
				:home,
				:images,
				:image_chooser,
				:inspiration,
				:lectures,
				:life,
				:links,
				:login,
				:multiples,
				:news,
				:paintings,
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
				:tooltip_artobject,
				:tooltip_image,
				:tooltip_poem,
				:update,
				:update_biographyitem,
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
				:city,
				:country,
				:email,
				:image_display_id,
				:image_title,
				:messagetxt,
				:lang,
				:location,
				:name,
				:search_query,
				:street,
				:surname,
				:target,
				:text,
				:title,
			]
			NUMERIC = [
				:artobject_id,
				:count,
				:link_id,
				:postal_code,
			]
			def display_id(value)
				value
			end
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
