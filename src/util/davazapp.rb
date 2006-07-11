#!/usr/bin/env ruby
# Util::DavazApp -- davaz.com -- 26.08.2005 -- mhuggler@ywesee.com

#require 'yus/session'
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
			def add_element(link_id, artobject_id)
				@db_manager.add_element(link_id, artobject_id)
			end
			def add_link(artobject_id, link_word)
				@db_manager.add_link(artobject_id, link_word)
			end
			def store_upload_image(image_file, artobject_id)
				Util::ImageHelper.store_upload_image(image_file, artobject_id)
			end
			def delete_image(artobject_id)
				Util::ImageHelper.delete_image(artobject_id)
			end
			def delete_link(link_id)
				@db_manager.delete_link(link_id)
			end
			def insert_guest(values_hsh)
				@db_manager.insert_guest(values_hsh)
			end
			def load_artgroup_artobjects(artgroup_id)
				@db_manager.load_artobjects_by_artgroup(artgroup_id)
			end
			def load_artgroups
				@db_manager.load_artgroups
			end
			def load_articles
					@db_manager.load_serie_artobjects('site_articles', 'series.name')
			end
			def load_article(artobject_id)
				@db_manager.load_artobject(artobject_id)
			end
			def load_artobject(artobject_id, select_by='artobject_id')
				@db_manager.load_artobject(artobject_id, select_by)
			end
			def load_country(id)
				@db_manager.load_country(id)
			end
			def load_countries
				@db_manager.load_countries
			end
			def load_currency_rates(model)
				@db_manager.load_currency_rates(model)
			end
			def load_images_by_tags(active_tags)
				@db_manager.load_images_by_tags(active_tags)
			end
			def load_exhibitions
				@db_manager.load_serie_artobjects('site_exhibitions', 'series.name')
			end
			def load_thefamily_text
				@db_manager.load_serie_artobjects('site_thefamily', 'series.name')
			end
			def load_guests
				@db_manager.load_guests
			end
			def load_hisfamily_text
				@db_manager.load_serie_artobjects('site_hisfamily', 'series.name')
			end
			def load_hisinspiration_text
				@db_manager.load_serie_artobjects('site_hisinspiration', 'series.name')
			end
			def load_hislife(lang)
				@db_manager.load_serie_artobjects("site_life_#{lang}", 'series.name')
			end
			def load_hiswork_text
				@db_manager.load_serie_artobjects('site_hiswork', 'series.name')
			end
			def load_image_tags
				@db_manager.load_image_tags
			end
			def load_links
				@db_manager.load_serie_artobjects('site_links', 'series.name')
			end
			def load_lectures
				@db_manager.load_serie_artobjects('site_lectures', 'series.name')
			end
			def load_material(id)
				@db_manager.load_material(id)
			end
			def load_materials
				@db_manager.load_materials
			end
			def load_news
				@db_manager.load_serie_artobjects('site_news', 'series.name')
			end
			def load_oneliner(location)
				@db_manager.load_oneliner(location)
			end
			def load_serie(serie_id, select_by='serie_id')
				@db_manager.load_serie(serie_id, select_by)
			end
			def load_series
				@db_manager.load_series("", load_artobjects=false)
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
			def load_shop_item(id)
				@db_manager.load_shop_item(id)
			end
			def load_tags
				@db_manager.load_tags
			end
			def load_tag_artobjects(tag)
				@db_manager.load_tag_artobjects(tag)
			end
			def load_tool(id)
				@db_manager.load_tool(id)
			end
			def load_tools
				@db_manager.load_tools
			end
			def load_movie(id)
				@db_manager.load_movie(id)
			end
			def load_movies
				@db_manager.load_artobjects_by_artgroup('MOV', true)
			end
			def load_movies_ticker
				@db_manager.load_artobject_ids('MOV')
			end
			def load_multiples
				@db_manager.load_artobjects_by_artgroup('MUL')
			end
			def login(email, pass)
				YUS_SERVER.login(email, pass, YUS_DOMAIN)
			end
			def remove_element(artobject_id, link_id)
				@db_manager.remove_element(artobject_id, link_id)
			end
			def search_artobjects(query, artgroup_id)
				if(query.nil?)
					@db_manager.load_artobjects_by_artgroup(artgroup_id)
				else
					@db_manager.search_artobjects(query)
				end
			end
		end
	end
end
