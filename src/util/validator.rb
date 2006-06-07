#!/usr/bin/env ruby
# Validator -- davaz.com -- 19.07.2005 -- mhuggler@ywesee.com

require 'sbsm/validator'
require 'cgi'

module DAVAZ
	module Util
		class Validator < SBSM::Validator
			EVENTS = [ 
				:add_entry,
				:ajax_article,
				:ajax_shop,
				:article,
				:articles,
				:artobject,
				:back,
				:bottleneck,
				:design,
				:drawings,
				:exhibitions,
				:family,
				:gallery,
				:gallery_search,
				:guestbook,
				:guestbookentry,
				:home,
				:images,
				:init, 
				:inspiration,
				:lectures,
				:life,
				:links,
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
				:movies,
				:work,
			]
			ZONES = [ 
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
				:city,
				:country,
				:messagetxt,
				:lang,
				:name,
				:search_query,
				:street,
				:surname,
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
