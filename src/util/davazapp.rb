#!/usr/bin/env ruby
# Util::DavazApp -- davaz.com -- 26.08.2005 -- mhuggler@ywesee.com

require 'yus/session'
require 'util/updater'

module DAVAZ
	module Util
		class DavazApp
			RUN_UPDATER = true 
			YUS_SERVER = DRb::DRbObject.new(nil, YUS_URI)
			attr_accessor :db_manager
			def initialize
				if(RUN_UPDATER)
					run_updater
				end
			end
			def run_updater
				day = 24 * 60 * 60
				Thread.new {
					Thread.current.priority=-5
					Thread.current.abort_on_exception = false 
					loop {
						sleep(day - (Time.now.to_i % day))
						Updater.new(self).run
					}
				}
			end
			def insert_displayelement(values)
				@db_manager.insert_displayelement(values)
			end
			def insert_guest(values_hsh)
				@db_manager.insert_guest(values_hsh)
			end
			def add_image_to_link(link_id, display_id)
				@db_manager.add_image_to_link(link_id, display_id)
			end
			def load_artgroups
				@db_manager.load_artgroups
			end
			def load_articles
				@db_manager.load_displayelements(nil, 'articles', 'position', 'ASC')
			end
			def load_article(display_id)
				@db_manager.load_displayelement('display_id', display_id)
			end
			def load_artobject(artobject_id)
				@db_manager.load_artobject(artobject_id)
			end
			def load_biography_text(lang)
				@db_manager.load_displayelements(nil, lang, 'title', 'DESC')
			end
			def load_country(id)
				@db_manager.load_country(id)
			end
			def load_cv(title)
				@db_manager.load_displayelement('title', title)	
			end
			def load_currency_rates(model)
				@db_manager.load_currency_rates(model)
			end
			def load_displayelement(display_id)
				@db_manager.load_displayelement('display_id', display_id)
			end
			def load_display_images
				@db_manager.load_display_images
			end
			def load_display_link(link_id)
				@db_manager.load_display_link(link_id)
			end
			def load_exhibitions
				@db_manager.load_displayelements(nil, 'exhibitions', 'title')
			end
			def load_thefamily_text
				@db_manager.load_displayelements(nil, 'thefamily', 'position', 'ASC')
			end
			def load_guests
				@db_manager.load_guests
			end
			def load_hisfamily_text
				@db_manager.load_displayelements(nil, 'hisfamily', 'position', 'ASC')
			end
			def load_hisinspiration_text
				@db_manager.load_displayelements(nil, 'hisinspiration', 'position', 'ASC')
			end
			def load_hiswork_text
				@db_manager.load_displayelements(nil, 'hiswork', 'position', 'ASC')
			end
			def load_link_displayelement(link_id)
				@db_manager.load_link_displayelement(link_id)
			end
			def load_link_displayelements(link_id)
				@db_manager.load_link_displayelements(link_id)
			end
			def load_lectures
				@db_manager.load_displayelements(nil, 'lectures', 
					'title DESC,', 'position ASC')
			end
			def load_links
				@db_manager.load_displayelements(nil, 'links', 'position', 'ASC')
			end
			def load_material(id)
				@db_manager.load_material(id)
			end
			def load_news
				@db_manager.load_news
			end
			def load_oneliner(location)
				@db_manager.load_oneliner(location)
			end
			def load_poem(link_id)
				if(link_id.to_i == 0)
					@db_manager.load_displayelement('title', link_id)
				else
					@db_manager.load_link_displayelements(link_id)
				end
			end
			def load_serie(serie_id)
				@db_manager.load_serie(serie_id)
			end
			def load_series
				@db_manager.load_series
			end
			def load_series_by_artgroup(artgroup_id)
				@db_manager.load_series_by_artgroup(artgroup_id)
			end
=begin
			def load_serie_objects(table_class, artgroup_id, serie_id)
				@db_manager.load_serie_objects(table_class, artgroup_id, serie_id)
			end
=end
			def load_shop_artgroups
				@db_manager.load_artgroups('shop_order')
			end
			def load_shop_items
				@db_manager.load_shop_items
			end
			def load_shop_artobject(artobject_id)
				@db_manager.load_shop_artobject(artobject_id)
			end
			def load_shop_item(id)
				@db_manager.load_shop_item(id)
			end
			def load_slideshow(title)
				@db_manager.load_slideshow(title)
			end
			def load_tool(id)
				@db_manager.load_tool(id)
			end
			def load_movie(id)
				@db_manager.load_movie(id)
			end
			def load_movies
				@db_manager.load_artobjects('MOV')
			end
			def load_multiples
				@db_manager.load_artobjects('MUL')
			end
			def login(email, pass)
				YUS_SERVER.login(email, pass, YUS_DOMAIN)
			end
			def remove_image_from_link(link_id, display_id)
				@db_manager.remove_image_from_link(link_id, display_id)
			end
			def search_artobjects(query, artgroup_id)
				if(query.nil?)
					@db_manager.load_artobjects(artgroup_id)
				else
					@db_manager.search_artobjects(query, artgroup_id)
				end
			end
			def update_displayelement(display_id, update_hash)
				@db_manager.update_displayelement(display_id, update_hash)
			end
		end
	end
end
