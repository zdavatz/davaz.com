require 'yus/session'
require 'sbsm/app'
require 'util/updater'
require 'util/image_helper'
require 'util/trans_handler.davaz'
require 'util/config'
require 'util/session'
require 'util/validator'
require 'util/db_manager' unless defined?(DaVaz::Stub)

module DaVaz::Util
  class App < SBSM::App
    attr_accessor :db_manager, :yus_server
    attr_reader :trans_handler, :validator, :drb_uri
    SESSION = Session

    def initialize
      run_updater if DaVaz.config.run_updater
      SBSM.logger= ChronoLogger.new(DaVaz.config.log_pattern)
      SBSM.logger.level = :debug
      @drb_uri = DaVaz.config.server_uri
      @yus_server = DaVaz.config.yus_server ?  DaVaz.config.yus_server : DRb::DRbObject.new(DaVaz.config.yus_server, DaVaz.config.yus_uri)
      @db_manager =  DaVaz.config.db_manager
      @db_manager ||= DaVaz::Util::DbManager.new
      res = super(:app => self, :validator => Validator.new, :trans_handler => DaVaz::Util::TransHandler.instance, :drb_uri => @drb_uri)
      SBSM.info "DaVaz::AppWebrick.new  drb #{@drb_uri} validator #{@validator} th #{@trans_handler} with log_pattern #{DaVaz.config.log_pattern} db #{@db_manager.class} #{SBSM.logger.level}"
      res
    end

    def run_updater
      day = 24 * 60 * 60
      Thread.new {
        Thread.current.priority           = -5
        Thread.current.abort_on_exception = false 
        loop {
          sleep(day - (Time.now.to_i % day))
          Updater.new(self).run
        }
      }
    end

    # actions

    def add_element(link_id, artobject_id)
      @db_manager.add_element(link_id, artobject_id)
    end

    def add_link(artobject_id, link_word)
      @db_manager.add_link(artobject_id, link_word)
    end

    def add_serie(serie_name)
      @db_manager.add_serie(serie_name)
    end

    def add_tool(tool_name)
      @db_manager.add_tool(tool_name)
    end

    def add_material(material_name)
      @db_manager.add_material(material_name)
    end

    def insert_artobject(values_hash)
      @db_manager.insert_artobject(values_hash)
    end

    def insert_guest(values_hsh)
      @db_manager.insert_guest(values_hsh)
    end

    def insert_oneliner(values_hash)
      @db_manager.insert_oneliner(values_hash)
    end

    def insert_link(values_hash)
      @db_manager.insert_link(values_hash)
    end

    def delete_artobject(artobject_id)
      DaVaz::Util::ImageHelper.delete_image(artobject_id)
      @db_manager.delete_artobject(artobject_id)
    end

    def delete_guest(guest_id)
      @db_manager.delete_guest(guest_id)
    end

    def delete_image(artobject_id)
      DaVaz::Util::ImageHelper.delete_image(artobject_id)
    end

    def delete_link(link_id)
      @db_manager.delete_link(link_id)
    end

    def delete_oneliner(oneliner_id)
      @db_manager.delete_oneliner(oneliner_id)
    end

    def delete_link(link_id)
      @db_manager.delete_link(link_id)
    end

    def remove_element(artobject_id, link_id)
      @db_manager.remove_element(artobject_id, link_id)
    end

    def remove_serie(serie_id)
      @db_manager.remove_serie(serie_id)
    end

    def remove_tool(tool_id)
      @db_manager.remove_tool(tool_id)
    end

    def remove_material(material_id)
      @db_manager.remove_material(material_id)
    end

    def update_artobject(artobject_id, update_hash)
      @db_manager.update_artobject(artobject_id, update_hash)
    end

    def update_guest(guest_id, update_hash)
      @db_manager.update_guest(guest_id, update_hash)
    end

    def update_oneliner(oneliner_id, update_hash)
      @db_manager.update_oneliner(oneliner_id, update_hash)
    end

    def update_link(link_id, update_hash)
      @db_manager.update_link(link_id, update_hash)
    end

    # counting

    def count_serie_artobjects(serie_id)
      @db_manager.count_artobjects('serie_id', serie_id)
    end

    def count_tool_artobjects(tool_id)
      @db_manager.count_artobjects('tool_id', tool_id)
    end

    def count_material_artobjects(material_id)
      @db_manager.count_artobjects('material_id', material_id)
    end

    # loading

    def load_artgroup_artobjects(artgroup_id)
      @db_manager.load_artobjects_by_artgroup(artgroup_id)
    end

    def load_artgroups
      @db_manager.load_artgroups
    end

    def load_articles
      @db_manager.load_serie_artobjects('Site Articles', 'series.name')
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

    def load_images_by_tag(tag_name)
      @db_manager.load_images_by_tag(tag_name)
    end

    def load_exhibitions
      @db_manager.load_serie_artobjects('Site Exhibitions', 'series.name')
    end

    def load_thefamily_text
      @db_manager.load_serie_artobjects('Site The Family', 'series.name')
    end

    def load_guest(guest_id)
      @db_manager.load_guest(guest_id)
    end

    def load_guests
      @db_manager.load_guests
    end

    def load_hisfamily_text
      @db_manager.load_serie_artobjects('Site His Family', 'series.name')
    end

    def load_hisinspiration_text
      @db_manager.load_serie_artobjects('Site His Inspiration', 'series.name')
    end

    def load_hislife(lang)
      @db_manager.load_serie_artobjects("Site His Life #{lang}", 'series.name')
    end

    def load_hiswork_text
      @db_manager.load_serie_artobjects('Site His Work', 'series.name')
    end

    def load_image_tags
      @db_manager.load_image_tags
    end

    def load_links
      @db_manager.load_serie_artobjects('Site Links', 'series.name')
    end

    def load_lectures
      @db_manager.load_serie_artobjects('Site Lectures', 'series.name')
    end

    def load_material(id)
      @db_manager.load_material(id)
    end

    def load_material_artobject_id(material_id)
      @db_manager.load_element_artobject_id('material_id', material_id)
    end

    def load_materials
      @db_manager.load_materials
    end

    def load_movie(id)
      @db_manager.load_movie(id)
    end

    def load_movies
      @db_manager.load_movies
    end

    def load_movies_ticker
      SBSM.info "@db_manager is #{@db_manager}"
      @db_manager.load_artobject_ids('MOV')
    end

    def load_multiples
      @db_manager.load_artobjects_by_artgroup('MUL')
    end

    def load_news
      @db_manager.load_serie_artobjects('Site News', 'series.name')
    end

    def load_oneliners
      @db_manager.load_oneliners
    end

    def load_oneliner(oneliner_id)
      @db_manager.load_oneliner(oneliner_id)
    end

    def load_oneliner_by_location(location)
      @db_manager.load_oneliner_by_location(location)
    end

    def load_serie(serie_id, select_by='serie_id')
      @db_manager.load_serie(serie_id, select_by)
    end

    def load_serie_artobject_id(serie_id)
      @db_manager.load_element_artobject_id('serie_id', serie_id)
    end

    def load_serie_id(name)
      @db_manager.load_serie_id(name)
    end

    def load_series
      @db_manager.load_series('', load_artobjects=false)
    end

    def load_series_by_artgroup(artgroup_id)
      @db_manager.load_series_by_artgroup(artgroup_id)
    end

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

    def load_tool_artobject_id(tool_id)
      @db_manager.load_element_artobject_id('tool_id', tool_id)
    end

    def load_tools
      @db_manager.load_tools
    end

    def load_links
      @db_manager.load_links
    end

    def load_link(link_id)
      @db_manager.load_link(link_id)
    end

    # search

    def search_artobjects(query, artgroup_id)
      if(query.nil? || query.empty?)
        @db_manager.load_artobjects_by_artgroup(artgroup_id)
      else
        @db_manager.search_artobjects(query)
      end
    end

    # save file

    def store_upload_image(image_file, artobject_id)
      DaVaz::Util::ImageHelper.store_upload_image(image_file, artobject_id)
    end

    # login/logout

    def login(email, password)
      SBSM.info "#{email} pw #{password} domain #{DaVaz.config.yus_domain}"
      res = @yus_server.login(email, password, DaVaz.config.yus_domain)
      SBSM.info "res for #{email} is #{res}"
      res
    end

    def login_token(email, token)
      SBSM.info "#{email} pw #{password} domain #{DaVaz.config.yus_domain}"
      res = @yus_server.login_token(email, token, DaVaz.config.yus_domain)
      SBSM.info "token for #{email} is #{token}  res #{res}"
      res
    end

    def logout(yus_session)
      SBSM.info "@yus_server #{@yus_server.inspect}"
      @yus_server.logout(yus_session) if @yus_server
    end
  end
end
