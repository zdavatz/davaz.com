require 'ftools'
require 'date'
require 'mysql2'
require 'yaml'
require 'model/art_group'
require 'model/art_object'
require 'model/country'
require 'model/guest'
require 'model/link'
require 'model/material'
require 'model/oneliner'
require 'model/serie'
require 'model/tag'
require 'model/tool'

module DaVaz
  module Util
    class DbConnection
      attr_reader :connection

      DB_CONNECTION_DATA = File.expand_path(
        '../../etc/db_connection_data.yml', File.dirname(__FILE__))

      @@db_data = YAML.load(File.read(DB_CONNECTION_DATA))

      def initialize
        reconnect
      end

      def reconnect
        @connection = connection
      end

      def connection
        Mysql2::Client.new(
          host:      @@db_data['host'],
          username:  @@db_data['user'],
          password:  @@db_data['password'],
          database:  @@db_data['db'],
          encoding:  @@db_data['encoding']  || 'utf8',
          reconnect: @@db_data['reconnect'] || true
        )
      end

      # @todo Remove retry, Improve delegation
      def method_missing(*args, &block)
        @connection.send(*args, &block)
      rescue Exception => e
        puts e.class, e.message
        retries ||= 2
        if retries > 0
          sleep 2 - retries
          retries -= 1
          reconnect
          retry
        end
      end
    end

    class DbManager

      def add_serie(serie_name)
        transaction do |conn|
          result = conn.query(<<~SQL.gsub(/\n/, ''))
            SELECT serie_id FROM series
          SQL
          key = result.map { |row| row['serie_id'] }.sort.last.succ
          conn.query(<<~SQL.gsub(/\n/, ''))
            INSERT INTO series VALUES ('#{key}', '#{serie_name}')
          SQL
          conn.affected_rows
        end
      end

      def add_tool(tool_name)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          INSERT INTO tools VALUES ('', '#{tool_name}')
        SQL
      end

      def add_material(material_name)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          INSERT INTO materials VALUES ('', '#{material_name}')
        SQL
      end

      def count_artobjects(by, id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT count(*) FROM artobjects WHERE #{by} = '#{id}'
        SQL
        return 0 unless result
        result.first['count(*)']
      end

      def delete_artobject(artobject_id)
        transaction do |conn|
          conn.query(<<~SQL.gsub(/\n/, ''))
            DELETE FROM artobjects
             WHERE artobject_id='#{artobject_id}'
          SQL
          deleted = conn.affected_rows
          if deleted > 0
            conn.query(<<~SQL.gsub(/\n/, ''))
              DELETE FROM links_artobjects
               WHERE artobject_id='#{artobject_id}'
            SQL
            conn.query(<<~SQL.gsub(/\n/, ''))
              DELETE FROM tags_artobjects
               WHERE artobject_id='#{artobject_id}'
            SQL
          end
          deleted
        end
      end

      def delete_guest(guest_id)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          DELETE FROM guestbook WHERE guest_id='#{guest_id}'
        SQL
      end

      def delete_oneliner(oneliner_id)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          DELETE FROM oneliner WHERE oneliner_id = '#{oneliner_id}'
        SQL
      end

      def delete_link(link_id)
        result = 0
        transaction do |conn|
          link = load_link(link_id)
          if link
            query_affected_rows(<<~SQL.gsub(/\n/, ''))
              DELETE FROM links WHERE link_id =
               '#{conn.escape(link.link_id.to_s)}'
            SQL
            result = query_affected_rows(<<~SQL.gsub(/\n/, ''))
              DELETE FROM links_artobjects WHERE link_id =
               '#{conn.escape(link.link_id.to_s)}'
            SQL
          end
        end
        result
      end

      def load_artgroups(order_by='artgroup_id')
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM artgroups ORDER BY #{order_by} ASC;
        SQL
        artgroups = []
        result.each { |key, value|
          model = DaVaz::Model::ArtGroup.new
          key.each { |col_name, col_value|
            model.send(col_name.to_s + '=', col_value)
          }
          artgroups.push(model)
        }
        artgroups
      end

      def load_artobject_links(artobject_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT links.*, artobjects.*
           FROM links
           JOIN links_artobjects USING (link_id)
           JOIN artobjects
           ON links_artobjects.artobject_id = artobjects.artobject_id
           WHERE links.artobject_id = '#{artobject_id}'
           ORDER BY links.word
        SQL
        links = {}
        result.each { |row|
          link_id = row['link_id']
          if links.has_key?(link_id)
            link = links[link_id]
          else
            link = DaVaz::Model::Link.new
            links.store(link_id, link)
          end
          artobject = DaVaz::Model::ArtObject.new
          set_attributes(link, row)
          set_attributes(artobject, row)
          link.artobjects.push(artobject)
        }
        links.values
      end

      def load_artobject_series(artobject_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT series.*
           FROM series_artobjects
           LEFT OUTER JOIN series
           ON series_artobjects.serie_id = series.serie_id
           WHERE series_artobjects.artobject_id = '#{artobject_id}'
        SQL
        result.map { |row|
          serie = DaVaz::Model::Serie.new
          serie.serie_id = row['serie_id']
          serie.name     = row['name']
          serie
        }
      end

      def load_artobject_tags(artobject_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT tags.*
           FROM artobjects
           LEFT OUTER JOIN tags_artobjects USING (artobject_id)
           LEFT OUTER JOIN tags
           ON tags.tag_id = tags_artobjects.tag_id
           WHERE artobjects.artobject_id = '#{artobject_id}'
           ORDER BY tags.name
        SQL
        result.map { |row|
          tag = DaVaz::Model::Tag.new
          tag.tag_id = row['tag_id']
          tag.name   = row['name']
          tag
        }
      end

      def load_artobjects(where, reverse=false)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.*,
           artgroups.name AS artgroup,
           materials.name AS material,
           series.name AS serie,
           tools.name AS tool,
           countries.name AS country
           FROM artobjects
           LEFT OUTER JOIN artgroups
           ON artobjects.artgroup_id = artgroups.artgroup_id
           LEFT OUTER JOIN materials
           ON artobjects.material_id = materials.material_id
           LEFT OUTER JOIN series
           ON artobjects.serie_id = series.serie_id
           LEFT OUTER JOIN tools
           ON artobjects.tool_id = tools.tool_id
           LEFT OUTER JOIN countries
           ON artobjects.country_id = countries.country_id
           #{where}
           ORDER BY
           artobjects.serie_position, artobjects.date ASC,
           artobjects.title #{'DESC' if reverse}
        SQL
        artobjects = []
        table = {}
        result.each { |key, value|
          model = DaVaz::Model::ArtObject.new
          key.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          table.store model.artobject_id, model
          artobjects.push(model)
        }
        load_artobjects_links(table.keys).each do |id, links|
          table[id].links.concat links
        end
        load_artobjects_tags(table.keys).each do |id, tags|
          table[id].tags.concat tags
        end
        artobjects
      end

      def load_artobject_ids(artgroup_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobject_id, artgroup_id, url
           FROM artobjects
           WHERE artgroup_id = '#{artgroup_id}'
           ORDER BY title DESC
        SQL
        result.map { |row|
          model = DaVaz::Model::ArtObject.new
          model.artobject_id = row['artobject_id']
          model.artgroup_id  = row['artgroup_id']
          model.url          = row['url']
          model
        }
      end

      def load_artobject(artobject_id, select_by='artobject_id')
        load_artobjects(<<~SQL.gsub(/\n/, '')).first
          WHERE artobjects.#{select_by}='#{artobject_id}'
        SQL
      end

      def load_artobjects_by_artgroup(artgroup_id, reverse=false)
        order_by = <<~SQL.gsub(/\n/, '')
          artobjects.serie_position,artobjects.date
           ASC,artobjects.title #{"DESC" if reverse}
        SQL
        if artgroup_id == 'MOV'
          order_by = 'artobjects.title'
        end
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.*,
           artgroups.name AS artgroup,
           materials.name AS material,
           series.name AS serie,
           tools.name AS tool,
           countries.name AS country
           FROM artobjects
           LEFT OUTER JOIN artgroups
           ON artobjects.artgroup_id = artgroups.artgroup_id
           LEFT OUTER JOIN materials
           ON artobjects.material_id = materials.material_id
           LEFT OUTER JOIN series
           ON artobjects.serie_id = series.serie_id
           LEFT OUTER JOIN tools
           ON artobjects.tool_id = tools.tool_id
           LEFT OUTER JOIN countries
           ON artobjects.country_id = countries.country_id
           WHERE artobjects.artgroup_id='#{artgroup_id}'
           ORDER BY #{order_by}
        SQL
        table = {}
        artobjects = []
        result.each { |row|
          model = DaVaz::Model::ArtObject.new
          row.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          table.store model.artobject_id, model
          artobjects.push(model)
        }
        load_artobjects_links(table.keys).each do |id, links|
          table[id].links.concat links
        end
        load_artobjects_tags(table.keys).each do |id, tags|
          table[id].tags.concat tags
        end
        artobjects
      end

      def load_artobjects_by_location(location)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT locations.*
           FROM locations
           WHERE locations.location = '#{location}'
        SQL
        artobjects = []
        result.each { |row|
          artobject = load_artobject(row['artobject_id'])
          artobject.serie_position = row['position']
          artobjects.push(artobject)
        }
        artobjects.sort { |a, b| a.serie_position <=> b.serie_position }
      end

      def load_artobjects_links(artobject_ids)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT links.artobject_id AS reference, links.*, artobjects.*
           FROM links
           JOIN links_artobjects USING (link_id)
           JOIN artobjects
           ON links_artobjects.artobject_id = artobjects.artobject_id
           WHERE links.artobject_id IN ('#{artobject_ids.join("','")}')
           ORDER BY links.artobject_id, links.word
        SQL
        table = {}
        result.each { |row|
          artobject_id = row['reference']
          links = (table[artobject_id] ||= {})
          link_id = row['link_id']
          if links.has_key?(link_id)
            link = links[link_id]
          else
            link = DaVaz::Model::Link.new
            links.store(link_id, link)
          end
          artobject = DaVaz::Model::ArtObject.new
          set_attributes(link, row)
          set_attributes(artobject, row)
          link.artobjects.push(artobject)
        }
        table.collect do |id, links|
          [id, links.values]
        end
      end

      # @todo refactor
      def load_artobjects_tags(artobject_ids)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.artobject_id AS reference, tags.*
           FROM artobjects
           LEFT OUTER JOIN tags_artobjects USING (artobject_id)
           LEFT OUTER JOIN tags
           ON tags.tag_id = tags_artobjects.tag_id
           WHERE artobjects.artobject_id IN ('#{artobject_ids.join("','")}')
           ORDER BY tags.name
        SQL
        table = {}
        result.each { |row|
          if id = row['tag_id']
            artobject_id = row['reference']
            tags = (table[artobject_id] ||= [])
            tag = DaVaz::Model::Tag.new
            tag.tag_id = id
            tag.name = row['name']
            tags.push(tag)
          end
        }
        table
      end

      def load_country(id)
      end

      def load_countries
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM countries ORDER BY name
        SQL
        countries = []
        result.each { |row|
          model = DaVaz::Model::Country.new
          model.country_id = row['country_id']
          model.name = row['name']
          countries.push(model)
        }
        countries
      end

      def load_currency_rates
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM currencies
        SQL
        result.map { |key, value|
          [key['target'], key['rate'].to_f]
        }.to_h
      end

      # @todo refactor
      def load_element_artobject_id(element, element_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobject_id FROM artobjects
           WHERE #{element} = '#{element_id}'
        SQL
        result.each { |row|
          return row['artobject_id']
        }
      end

      def load_exhibitions
      end

      def load_guest(guest_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM guestbook WHERE guest_id='#{guest_id}'
        SQL
        create_model_array(DaVaz::Model::Guest, result).first
      end

      def load_guests
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM guestbook ORDER BY date DESC
        SQL
        create_model_array(DaVaz::Model::Guest, result)
      end

      def load_image_tags
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT tag_id,name FROM tags;
        SQL
        tags = []
        result.each { |key, value|
          model = DaVaz::Model::Tag.new
          key.each { |colname, colval|
            model.send(colname.to_s + '=', colval)
          }
          tags.push(model)
        }
        tags
      end

      def load_images_by_tag(tag_name)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.artobject_id
           FROM tags
           LEFT OUTER JOIN tags_artobjects
           ON tags.tag_id = tags_artobjects.tag_id
           LEFT OUTER JOIN artobjects
           ON tags_artobjects.artobject_id = artobjects.artobject_id
           WHERE tags.name = '#{tag_name}'
        SQL
        artobjects = []
        result.each { |row|
          artobject = DaVaz::Model::ArtObject.new
          set_attributes(artobject, row)
          artobjects.push(artobject)
        }
        artobjects
      end

      def load_materials
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM materials ORDER BY name
        SQL
        materials = []
        result.each { |row|
          model = DaVaz::Model::Material.new
          model.material_id = row['material_id']
          model.name        = row['name']
          materials.push(model)
        }
        materials
      end

      def load_movies
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.*,
           artgroups.name AS artgroup,
           materials.name AS material,
           series.name AS serie,
           tools.name AS tool,
           countries.name AS country
           FROM artobjects
           LEFT OUTER JOIN artgroups
           ON artobjects.artgroup_id = artgroups.artgroup_id
           LEFT OUTER JOIN materials
           ON artobjects.material_id = materials.material_id
           LEFT OUTER JOIN series
           ON artobjects.serie_id = series.serie_id
           LEFT OUTER JOIN tools
           ON artobjects.tool_id = tools.tool_id
           LEFT OUTER JOIN countries
           ON artobjects.country_id = countries.country_id
           WHERE artobjects.artgroup_id = 'MOV'
           ORDER BY artobjects.title DESC
        SQL
        artobjects = []
        table = {}
        result.each { |key, value|
          model = DaVaz::Model::ArtObject.new
          key.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          table.store model.artobject_id, model
          artobjects.push(model)
        }
        load_artobjects_links(table.keys).each do |id, links|
          table[id].links.concat links
        end
        load_artobjects_tags(table.keys).each do |id, tags|
          table[id].tags.concat tags
        end
        artobjects
      end

      def load_oneliners
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM oneliner
           ORDER BY location ASC, oneliner_id DESC
        SQL
        create_model_array(DaVaz::Model::Oneliner, result)
      end

      def load_oneliner(oneliner_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM oneliner
            WHERE active = 1
            AND oneliner_id = '#{oneliner_id}'
        SQL
        create_model_array(DaVaz::Model::Oneliner, result).first
      end

      def load_oneliner_by_location(location)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM oneliner
           WHERE active = 1
           AND location = '#{location}'
           ORDER BY location ASC, oneliner_id DESC
        SQL
        create_model_array(DaVaz::Model::Oneliner, result)
      end

      def load_series(where, load_artobjects=true)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT series.* FROM series #{where} ORDER BY name
        SQL
        series = []
        result.each { |row|
          serie = DaVaz::Model::Serie.new
          serie.serie_id = row['serie_id']
          serie.name = row['name']
          if(load_artobjects)
            artobjects = load_serie_artobjects(serie.serie_id)
            serie.artobjects.concat(artobjects)
          end
          series.push(serie)
        }
        series
      end

      def load_serie(serie_id, select_by='serie_id')
        load_series("WHERE #{select_by}='#{serie_id}'").first
      end

      def load_serie_artobjects(serie_id, select_by='series.serie_id')
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.*,
           artgroups.name AS artgroup,
           materials.name AS material,
           series.name AS serie,
           tools.name AS tool,
           countries.name AS country
           FROM series
           JOIN artobjects USING (serie_id)
           LEFT OUTER JOIN artgroups
           ON artobjects.artgroup_id = artgroups.artgroup_id
           LEFT OUTER JOIN materials
           ON artobjects.material_id = materials.material_id
           LEFT OUTER JOIN tools
           ON artobjects.tool_id = tools.tool_id
           LEFT OUTER JOIN countries
           ON artobjects.country_id = countries.country_id
           WHERE #{select_by}='#{serie_id}'
           ORDER BY artobjects.serie_position ASC,
           artobjects.date DESC,artobjects.title DESC
        SQL
        artobjects = []
        table = {}
        result.each { |key, value|
          model = DaVaz::Model::ArtObject.new
          key.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          table.store model.artobject_id, model
          artobjects.push(model)
        }
        load_artobjects_links(table.keys).each do |id, links|
          table[id].links.concat links
        end
        artobjects
      end

      def load_series_by_artgroup(artgroup_id)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT DISTINCT series.serie_id,series.name
           FROM artobjects
           JOIN series USING (serie_id)
           WHERE artobjects.artgroup_id='#{artgroup_id}'
           AND series.serie_id != 'AAA'
           AND series.name NOT LIKE 'Site %'
           ORDER BY series.name
        SQL
        array = []
        result.each { |key, value|
          model = DaVaz::Model::Serie.new
          key.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          array.push(model)
        }
        array
      end

      def load_serie_id(serie_name)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT serie_id FROM series
           WHERE name='#{serie_name}'
        SQL
        serie_id = ""
        result.each { |row|
          serie_id = row["serie_id"]
        }
        serie_id
      end

      def load_shop_item(artobject_id)
        rates = load_currency_rates
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.* FROM artobjects
           WHERE artobject_id='#{artobject_id}'
        SQL
        items = []
        result.each { |key, value|
          artobject = DaVaz::Model::ArtObject.new
          key.each { |column_name, column_value|
            artobject.send(column_name.to_s + '=', column_value)
          }
          artobject.dollar_price = (rates['USD'] * artobject.price.to_i).round
          artobject.euro_price = (rates['EURO'] * artobject.price.to_i).round
          items.push(artobject)
        }
        items.first
      end

      def load_shop_items()
        rates = load_currency_rates
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.*, artgroups.name AS artgroup
           FROM artobjects
           LEFT OUTER JOIN artgroups
           ON artobjects.artgroup_id = artgroups.artgroup_id
           WHERE price!='0'
           ORDER BY artobjects.title DESC
        SQL
        items = []
        result.each { |key, value|
          artobject = DaVaz::Model::ArtObject.new
          key.each { |column_name, column_value|
            artobject.send(column_name.to_s + '=', column_value)
          }
          artobject.dollar_price = (rates['USD']  * artobject.price.to_i).round
          artobject.euro_price   = (rates['EURO'] * artobject.price.to_i).round
          items.push(artobject)
        }
        items
      end

      def load_tags
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM tags
        SQL
        result.map { |row|
          tag = DaVaz::Model::Tag.new
          tag.tag_id = row['tag_id']
          tag.name   = row['name']
          tag
        }
      end

      def load_tag_artobjects(tag)
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT artobjects.*,
           artgroups.name AS artgroup,
           materials.name AS material,
           series.name AS serie,
           tools.name AS tool,
           countries.name AS country
           FROM tags
           LEFT OUTER JOIN tags_artobjects
           ON tags.tag_id = tags_artobjects.tag_id
           LEFT OUTER JOIN artobjects
           ON tags_artobjects.artobject_id = artobjects.artobject_id
           LEFT OUTER JOIN artgroups
           ON artobjects.artgroup_id = artgroups.artgroup_id
           LEFT OUTER JOIN materials
           ON artobjects.material_id = materials.material_id
           LEFT OUTER JOIN series
           ON artobjects.serie_id = series.serie_id
           LEFT OUTER JOIN tools
           ON artobjects.tool_id = tools.tool_id
           LEFT OUTER JOIN countries
           ON artobjects.country_id = countries.country_id
           WHERE tags.name = '#{tag}' OR series.name = '#{tag}'
        SQL
        artobjects = []
        result.each { |row|
          artobject = DaVaz::Model::ArtObject.new
          set_attributes(artobject, row)
          artobjects.push(artobject)
        }
        artobjects.concat(load_serie_artobjects(tag, 'series.name'))
        artobjects
      end

      def load_tools
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT * FROM tools ORDER BY name
        SQL
        result.map { |row|
          model = DaVaz::Model::Tool.new
          model.tool_id = row['tool_id']
          model.name = row['name']
          model
        }
      end

      def load_link(link_id)
        load_links.find {|link|
          link.link_id.to_s  == link_id.to_s
        }
      end

      def load_links
        result = connection.query(<<~SQL.gsub(/\n/, ''))
          SELECT
           links.link_id,
           links.artobject_id AS linked_artobject_id,
           links.word,
           artobjects.*
           FROM links
           JOIN links_artobjects USING (link_id)
           LEFT OUTER JOIN artobjects
           ON links_artobjects.artobject_id = artobjects.artobject_id
           ORDER BY links.link_id DESC, links.word ASC
        SQL
        links = {}
        result.each { |row|
          link_id             = row['link_id']
          linked_artobject_id = row['linked_artobject_id']
          key = "#{link_id}_#{linked_artobject_id}"
          if links.has_key?(key)
            link = links[key]
          else
            link = DaVaz::Model::Link.new
            link.artobject_id = linked_artobject_id
            links.store(key, link)
          end
          artobject = DaVaz::Model::ArtObject.new
          set_attributes(link, row, ['artobject_id'])
          set_attributes(artobject, row)
          link.artobjects.push(artobject)
        }
        links.values.select { |tt|
          tt.artobjects.length == 1
        }
      end

      def insert_artobject(values_hash)
        data = values_hash.map { |key, value|
          next if !value || key == :tags
          [key.to_s, "'#{connection.escape(value)}'"]
        }.compact.to_h
        artobject_id = nil
        transaction do |conn|
          result = conn.query(<<~SQL.gsub(/\n/, ''))
            INSERT INTO artobjects (#{data.keys.join(',')})
             VALUES (#{data.values.join(',')})
          SQL
          artobject_id = conn.last_id
          tags = values_hash[:tags]
          unless tags.nil? || tags.empty?
            tags.each do |tag|
              unless tag.empty?
                conn.query(<<~SQL.gsub(/\n/, ''))
                  INSERT INTO tags (name) VALUES ('#{tag}')
                   ON DUPLICATE KEY UPDATE
                   tag_id = LAST_INSERT_ID(tag_id), name = name
                SQL
                conn.query(<<~SQL.gsub(/\n/, ''))
                  INSERT INTO tags_artobjects (tag_id, artobject_id)
                   VALUES ('#{conn.last_id}', '#{artobject_id}')
                SQL
              end
            end
          end
        end
        artobject_id
      end

      def insert_guest(user_values)
        values = [Time.now.strftime('%Y-%m-%d')]
        %i{name city country email messagetxt}.each do |key|
          values.push(connection.escape(user_values[key].to_s))
        end
        connection.query(<<~SQL.gsub(/\n/, ''))
          INSERT INTO guestbook
           VALUES ('', '#{values.join("','")}')
        SQL
        connection.last_id
      end

      def insert_oneliner(user_values)
        values = %i{text location color size active}.map do |key|
          connection.escape(user_values[key].to_s)
        end
        connection.query(<<~SQL.gsub(/\n/, ''))
          INSERT INTO oneliner
           VALUES ('', '#{values.join("','")}')
        SQL
        connection.last_id
      end

      def insert_link(user_values)
        # linked_artobject_id => artobject_id
        values = %i{linked_artobject_id word}.map do |key|
          connection.escape(user_values[key].to_s)
        end
        link_id = nil
        transaction do |conn|
          conn.query(<<~SQL.gsub(/\n/, ''))
            INSERT INTO links
             VALUES ('', '#{values.join("','")}')
          SQL
          link_id = conn.last_id
          if link_id
            values = [link_id]
            values << conn.escape(user_values[:artobject_id].to_s)
            conn.query(<<~SQL.gsub(/\n/, ''))
              INSERT INTO links_artobjects
               VALUES ('#{values.join("','")}')
            SQL
          end
        end
        link_id
      end

      def create_model_array(model_class, result)
        array = []
        result.each { |key, value|
          model = model_class.new
          key.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          array.push(model)
        }
        array
      end

      def create_model_hash(model_class, result, hsh_key)
        hash = {}
        result.each { |key, value|
          model = model_class.new
          key.each { |column_name, column_value|
            model.send(column_name.to_s + '=', column_value)
          }
          hash.store(model.send(hsh_key), model)
        }
        hash
      end

      def remove_serie(serie_id)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          DELETE FROM series WHERE serie_id = '#{serie_id}'
        SQL
      end

      def remove_tool(tool_id)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          DELETE FROM tools WHERE tool_id = '#{tool_id}'
        SQL
      end

      def remove_material(material_id)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          DELETE FROM materials WHERE material_id = '#{material_id}'
        SQL
      end

      def search_artobjects(search_pattern)
        series = search_serie(search_pattern)
        serie_artobjects = series.collect { |serie|
          serie.artobjects
        }
        artobjects = load_artobjects(<<~SQL.gsub(/\n/, ''))
          WHERE artobjects.title REGEXP "#{search_pattern}"
        SQL
        serie_artobjects.flatten.concat(artobjects)
      end

      def search_serie(search_pattern)
        load_series(<<~SQL.gsub(/\n/, ''))
          WHERE series.name REGEXP "#{search_pattern}"
        SQL
      end

      # Updates artobject with tags
      def update_artobject(artobject_id, update_hash)
        transaction do |conn|
          delete_artobject_statement = conn.prepare(<<~SQL.gsub(/\n/, ''))
            DELETE FROM tags_artobjects WHERE artobject_id = ?
          SQL
          delete_artobject_statement.execute(artobject_id)
          tags = update_hash[:tags]
          if tags && !tags.empty?
            add_tag_statement = conn.prepare(<<~SQL.gsub(/\n/, ''))
              INSERT INTO tags (name) VALUES (?) ON DUPLICATE KEY UPDATE
               tag_id = LAST_INSERT_ID(tag_id), name = name
            SQL
            tags.each { |tag|
              next if tag.empty?
              add_tag_statement.execute(tag)
              tag_id = conn.last_id
              add_tag_relation_statement = conn.prepare(<<~SQL.gsub(/\n/, ''))
                INSERT INTO tags_artobjects (tag_id, artobject_id)
                 VALUES (?, ?)
              SQL
              add_tag_relation_statement.execute(tag_id, artobject_id)
            }
          end
          updated_attrs = update_hash.map { |key, val|
            next if key == :tags
            if key == :date_ch
              date = val.split('.')
              val = "#{date[2]}-#{date[1]}-#{date[0]}"
            elsif !val
              val = ''
            end
            "#{conn.escape(key.to_s)} = '#{conn.escape(val)}'"
          }.compact
          update_artobject_statement = conn.prepare(<<~SQL.gsub(/\n/, ''))
            UPDATE artobjects
             SET #{updated_attrs.join(', ')} WHERE artobject_id = ?
          SQL
          update_artobject_statement.execute(artobject_id)
          conn.affected_rows
        end
      end

      def update_currency(origin, target, rate)
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          UPDATE currencies
           SET rate = '#{rate}'
           WHERE origin = '#{origin}' AND target = '#{target}';
        SQL
      end

      def update_guest(guest_id, update_hash)
        values = update_hash.map { |key, value|
          next unless value
          next if key == :tags
          if key == :date_gb
            date = value.split('.')
            "date = '#{date[2]}-#{date[1]}-#{date[0]}'"
          else
            "#{key} = '#{connection.escape(value)}'"
          end
        }.compact
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          UPDATE guestbook
           SET #{values.join(', ')}
           WHERE guest_id = '#{guest_id}'
        SQL
      end

      def update_oneliner(oneliner_id, update_hash)
        values = update_hash.map { |key, value|
          next unless value
          "#{key} = '#{connection.escape(value)}'"
        }.compact
        query_affected_rows(<<~SQL.gsub(/\n/, ''))
          UPDATE oneliner
           SET #{values.join(', ')}
           WHERE oneliner_id = '#{oneliner_id}'
        SQL
      end

      def update_link(link_id, update_hash)
        transaction do |conn|
          # linked_artobject_id => artobject_id
          values = [:word, :linked_artobject_id].map { |key|
            value = update_hash[key]
            next unless value
            "#{key.to_s.gsub(/\Alinked_/, '')} = " \
            "'#{conn.escape(value)}'"
          }.compact
          query_affected_rows(<<~SQL.gsub(/\n/, ''))
            UPDATE links
             SET #{values.join(', ')}
             WHERE link_id = '#{link_id}'
          SQL
          values = [:artobject_id].map { |key|
            value = update_hash[key]
            next unless value
            "#{key} = '#{conn.escape(value)}'"
          }.compact
          query_affected_rows(<<~SQL.gsub(/\n/, ''))
            UPDATE links_artobjects
             SET #{values.join(', ')}
             WHERE link_id = '#{link_id}'
          SQL
        end
      end

      private

      def connect
        connection = DbConnection.new
        connection.reconnect
        connection.connection
      end

      def connection
        @connection ||= connect
        if block_given?
          yield @connection
        else
          @connection
        end
      rescue
      end

      def transaction(&block)
        raise ArgumentError unless block_given?
        connection do |conn|
          begin
            conn.query('BEGIN')
            yield(conn)
            conn.query('COMMIT')
            return true
          rescue Exception => e
            puts e.class, e.message
            conn.query('ROLLBACK')
            return false
          end
        end
      end

      def query_affected_rows(query)
        connection do |conn|
          conn.query(query)
          conn.affected_rows
        end
      end

      def set_attributes(model, row, excepts=[])
        row.each do |key, value|
          next if excepts.include?(key)
          method = key.to_s + '='
          model.send(method, value) if model.respond_to?(method)
        end
      end
    end
  end
end
