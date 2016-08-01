require 'ftools'
require 'date'
require 'mysql2'
require 'yaml'
require 'model/artgroup'
require 'model/country'
require 'model/guest'
require 'model/link'
require 'model/material'
require 'model/oneliner'
require 'model/serie'
require 'model/tag'
require 'model/tool'

module DAVAZ
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
				query = <<-EOS
					SELECT serie_id FROM series
				EOS
        connection { |conn|
          result = conn.query(query)
          keys = []
          result.each { |row|
            keys.push(row['serie_id'])	
          }
          query = <<-EOS
            INSERT INTO series
            VALUES ('#{keys.sort.last.succ}', '#{serie_name}')
          EOS
          conn.query(query)
          conn.affected_rows
        }
			end
			def add_tool(tool_name)
				query = <<-EOS
					INSERT INTO tools
					VALUES ('', '#{tool_name}')
				EOS
        query_affected_rows(query)
			end
			def add_material(material_name)
				query = <<-EOS
					INSERT INTO materials
					VALUES ('', '#{material_name}')
				EOS
        query_affected_rows(query)
			end
			def count_artobjects(by, id)
				query = <<-EOS
					SELECT count(*)	
					FROM artobjects
					WHERE #{by}='#{id}'
				EOS
        result = connection.query(query)
        count = ""
        result.each { |row|
          count = row['count(*)']
        }
        count
			end
			def delete_artobject(artobject_id)
				query = <<-EOS
					DELETE FROM artobjects
					WHERE artobject_id='#{artobject_id}'
				EOS
				connection { |conn|
          conn.query(query)
          deleted = conn.affected_rows
          if(deleted > 0)
            query = <<-EOS
              DELETE FROM links_artobjects
              WHERE artobject_id='#{artobject_id}'
            EOS
            conn.query(query)
            query = <<-EOS
              DELETE FROM tags_artobjects
              WHERE artobject_id='#{artobject_id}'
            EOS
            conn.query(query)
          end
          deleted
        }
			end
			def delete_guest(guest_id)
				query = <<-EOS
					DELETE FROM guestbook
					WHERE guest_id='#{guest_id}'
				EOS
        query_affected_rows(query)
			end
			def load_artgroups(order_by='artgroup_id')
				query = <<-EOS
					SELECT *
					FROM artgroups
					ORDER BY #{order_by} ASC;
				EOS
				result = connection.query(query)
				artgroups = []
				result.each { |key, value|
					model = DAVAZ::Model::Artgroup.new
					key.each { |col_name, col_value|
						model.send(col_name.to_s + '=', col_value)
					}
					artgroups.push(model)
				}		
				artgroups
			end
			def load_artobject_links(artobject_id)
				query = <<-EOS
					SELECT links.*, artobjects.* 
					FROM links
					JOIN links_artobjects USING (link_id) 
					JOIN artobjects
						ON links_artobjects.artobject_id = artobjects.artobject_id
					WHERE links.artobject_id = '#{artobject_id}'
					ORDER BY links.word
				EOS
				result = connection.query(query)
				links = {}
				result.each { |row|
					link_id = row['link_id'] 
					if(links.has_key?(link_id))
						link = links[link_id]
					else
						link = Model::Link.new
						links.store(link_id, link)
					end
					artobject = Model::ArtObject.new
					set_attributes(link, row)
					set_attributes(artobject, row)
					link.artobjects.push(artobject)
				}
				links.values
			end
			def load_artobject_series(artobject_id)
				query = <<-EOS
					SELECT series.* 
					FROM series_artobjects
					LEFT OUTER JOIN series
						ON series_artobjects.serie_id = series.serie_id
					WHERE series_artobjects.artobject_id = '#{artobject_id}'
				EOS
				result = connection.query(query)
				series = []
				result.each { |row|
					serie = Model::Serie.new
					serie.serie_id = row['serie_id']
					serie.name = row['name']
					series.push(serie)
				}
				series
			end
			def load_artobject_tags(artobject_id)
				query = <<-EOS
					SELECT tags.*
					FROM artobjects
					LEFT OUTER JOIN tags_artobjects USING (artobject_id) 
					LEFT OUTER JOIN tags
						ON tags.tag_id = tags_artobjects.tag_id
					WHERE artobjects.artobject_id = '#{artobject_id}'
					ORDER BY tags.name
				EOS
				result = connection.query(query)
				tags = []
				result.each { |row|
					tag = Model::Tag.new	
					tag.tag_id = row['tag_id']
					tag.name = row['name']
					tags.push(tag)
				}
				tags
			end
			def load_artobjects(where, reverse=false)
				query = <<-EOS
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
					ORDER BY artobjects.serie_position,artobjects.date ASC,artobjects.title #{"DESC" if reverse}
				EOS
				result = connection.query(query)
				artobjects = []
        table = {}
        result.each { |key, value|
          model = DAVAZ::Model::ArtObject.new
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
				query = <<-EOS
					SELECT artobject_id, artgroup_id, url
					FROM artobjects
					WHERE artgroup_id = '#{artgroup_id}'
					ORDER BY title DESC
				EOS
        result = connection.query(query) 
				ids = []
				result.each { |row|
					model = Model::ArtObject.new
					model.artobject_id = row['artobject_id']
					model.artgroup_id = row['artgroup_id']
					model.url = row['url']
					ids.push(model)
				}
				ids
			end
			def load_artobject(artobject_id, select_by='artobject_id')
				where = "WHERE artobjects.#{select_by}='#{artobject_id}'"
				load_artobjects(where).first
			end
			def load_artobjects_by_artgroup(artgroup_id, reverse=false)
				order_by = <<-EOS 
					artobjects.serie_position,artobjects.date ASC,artobjects.title #{"DESC" if reverse}
				EOS
				if(artgroup_id == 'MOV')
					order_by = 'artobjects.title'
				end
				query = <<-EOS
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
				EOS
				result = connection.query(query)
        table = {}
				artobjects = []
        result.each { |row|
          model = DAVAZ::Model::ArtObject.new
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
				query = <<-EOS
					SELECT locations.*
					FROM locations
					WHERE locations.location = '#{location}' 
				EOS
				result = connection.query(query)
				artobjects = []
				result.each { |row|
					artobject = load_artobject(row['artobject_id'])
					artobject.serie_position = row['position']
					artobjects.push(artobject)
				}
				artobjects.sort { |a, b| a.serie_position <=> b.serie_position }
			end
      def load_artobjects_links(artobject_ids)
        query = <<-EOS
          SELECT links.artobject_id AS reference, links.*, artobjects.*
          FROM links
          JOIN links_artobjects USING (link_id)
          JOIN artobjects
            ON links_artobjects.artobject_id = artobjects.artobject_id
          WHERE links.artobject_id IN ('#{artobject_ids.join("','")}')
          ORDER BY links.artobject_id, links.word
        EOS
        result = connection.query(query)
        table = {}
        result.each { |row|
          artobject_id = row['reference']
          links = (table[artobject_id] ||= {})
          link_id = row['link_id']
          if(links.has_key?(link_id))
            link = links[link_id]
          else
            link = Model::Link.new
            links.store(link_id, link)
          end
          artobject = Model::ArtObject.new
          set_attributes(link, row)
          set_attributes(artobject, row)
          link.artobjects.push(artobject)
        }
        table.collect do |id, links|
          [id, links.values]
        end
      end
      def load_artobjects_tags(artobject_ids)
        query = <<-EOS
          SELECT artobjects.artobject_id AS reference, tags.*
          FROM artobjects
          LEFT OUTER JOIN tags_artobjects USING (artobject_id)
          LEFT OUTER JOIN tags
            ON tags.tag_id = tags_artobjects.tag_id
          WHERE artobjects.artobject_id IN ('#{artobject_ids.join("','")}')
          ORDER BY tags.name
        EOS
        result = connection.query(query)
        table = {}
        result.each { |row|
          if id = row['tag_id']
            artobject_id = row['reference']
            tags = (table[artobject_id] ||= [])
            tag = Model::Tag.new
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
				query = <<-EOS
					SELECT *
					FROM countries
					ORDER BY name
				EOS
				result = connection.query(query)
				countries = []
				result.each { |row|
					model = Model::Country.new
					model.country_id = row['country_id']
					model.name = row['name']
					countries.push(model)
				}
				countries
			end
			def load_currency_rates
				query = <<-EOS
					SELECT * 
					FROM currencies
				EOS
				result = connection.query(query)
				rates = {}
				result.each { |key, value|
					rates.store(key['target'], key['rate'].to_f)
				}
				rates
			end
			def load_element_artobject_id(element, element_id)
				query = <<-EOS
					SELECT artobject_id
					FROM artobjects
					WHERE #{element} = '#{element_id}'
				EOS
				result = connection.query(query)
				result.each { |row|
					return row['artobject_id']
				}
			end
			def load_exhibitions
			end
			def load_guest(guest_id)
				query = <<-EOS
					SELECT *
					FROM guestbook
					WHERE guest_id='#{guest_id}'
				EOS
				result = connection.query(query)
				create_model_array(DAVAZ::Model::Guest, result).first
			end
			def load_guests
				query = <<-EOS
					SELECT *
					FROM guestbook
					ORDER BY date DESC
				EOS
				result = connection.query(query)
				create_model_array(DAVAZ::Model::Guest, result) 
			end
			def load_image_tags
				sql = <<-SQL
					SELECT tag_id,name FROM tags;
				SQL
				tags = []
				result = connection.query(sql)
				result.each { |key, value|
					model = DAVAZ::Model::Tag.new
					key.each { |colname, colval|
						model.send(colname.to_s + '=', colval)
					}
					tags.push(model)
				}
				tags
			end
			def load_images_by_tag(tag_name)
				query = <<-EOS
					SELECT artobjects.artobject_id
					FROM tags
					LEFT OUTER JOIN tags_artobjects
						ON tags.tag_id = tags_artobjects.tag_id
					LEFT OUTER JOIN artobjects
						ON tags_artobjects.artobject_id = artobjects.artobject_id
					WHERE tags.name = '#{tag_name}'
				EOS
				result = connection.query(query)
				artobjects = []
				result.each { |row|
					artobject = Model::ArtObject.new
					set_attributes(artobject, row)
					artobjects.push(artobject)
				}
				artobjects
			end
			def load_materials
				query = <<-EOS
					SELECT *
					FROM materials
					ORDER BY name
				EOS
				result = connection.query(query)
				materials = []
				result.each { |row|
					model = Model::Material.new
					model.material_id = row['material_id']
					model.name = row['name']
					materials.push(model)
				}
				materials
			end
			def load_movies
				query = <<-EOS
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
				EOS
				result = connection.query(query)
				artobjects = []
        table = {}
        result.each { |key, value|
          model = DAVAZ::Model::ArtObject.new
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
			def load_oneliner(location)
				sql = <<-SQL
					SELECT * FROM oneliner WHERE location='#{location}'; 
				SQL
				result = connection.query(sql)
				create_model_array(DAVAZ::Model::OneLiner, result) 
			end
			def load_series(where, load_artobjects=true)
				query = <<-EOS
					SELECT series.*
					FROM series
					#{where}
					ORDER BY name
				EOS
				result = connection.query(query)
				series = []
				result.each { |row|
					serie = Model::Serie.new		
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
				where = <<-EOS
					WHERE #{select_by}='#{serie_id}'
				EOS
				load_series(where).first
			end
			def load_serie_artobjects(serie_id, select_by='series.serie_id')
				query = <<-EOS
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
					ORDER BY artobjects.serie_position ASC,artobjects.date DESC,artobjects.title DESC
				EOS
				result = connection.query(query)
				artobjects = []
        table = {}
        result.each { |key, value|
          model = DAVAZ::Model::ArtObject.new
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
				sql = <<-SQL
					SELECT DISTINCT series.serie_id,series.name 
					FROM artobjects
					JOIN series USING (serie_id)
					WHERE artobjects.artgroup_id='#{artgroup_id}' 
          AND series.serie_id != 'AAA' 
          AND series.name NOT LIKE 'Site %'
					ORDER BY series.name
				SQL
				result = connection.query(sql)
				array = []
				result.each { |key, value|
					model = Model::Serie.new 
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
          array.push(model)
				}
				array
			end
			def load_serie_id(serie_name)
				query = <<-EOS
					SELECT serie_id FROM series
					WHERE name='#{serie_name}'
				EOS
				result = connection.query(query)
				serie_id = ""
				result.each { |row|
					serie_id = row["serie_id"]
				}
				serie_id
			end
			def load_shop_item(artobject_id)
        rates = load_currency_rates
				query = <<-EOS
					SELECT artobjects.*
					FROM artobjects
					WHERE artobject_id='#{artobject_id}'
				EOS
				result = connection.query(query)
				items = []
				result.each { |key, value|
					artobject = DAVAZ::Model::ArtObject.new 
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
				query = <<-EOS
					SELECT artobjects.*, artgroups.name AS artgroup
					FROM artobjects
					LEFT OUTER JOIN artgroups
					ON artobjects.artgroup_id = artgroups.artgroup_id
					WHERE price!='0'
					ORDER BY artobjects.title DESC 
				EOS
				result = connection.query(query)
				items = []
				result.each { |key, value|
					artobject = DAVAZ::Model::ArtObject.new 
					key.each { |column_name, column_value| 
						artobject.send(column_name.to_s + '=', column_value)
					}
					artobject.dollar_price = (rates['USD'] * artobject.price.to_i).round
					artobject.euro_price = (rates['EURO'] * artobject.price.to_i).round
					items.push(artobject)
				}
				items
			end
			def load_tags
				query = <<-EOS
					SELECT *
					FROM tags
				EOS
				result = connection.query(query)
				tags = []
				result.each { |row|
					tag = Model::Tag.new 
					tag.tag_id = row['tag_id']
					tag.name = row['name']
					tags.push(tag)
				}
				tags
			end
			def load_tag_artobjects(tag)
				query = <<-EOS
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
				EOS
				result = connection.query(query)
				artobjects = []
				result.each { |row|
					artobject = Model::ArtObject.new
					set_attributes(artobject, row)
					artobjects.push(artobject)
				}
				artobjects.concat(load_serie_artobjects(tag, 'series.name'))
				artobjects
			end
			def load_tools
				query = <<-EOS
					SELECT *
					FROM tools
					ORDER BY name
				EOS
				result = connection.query(query)
				tools = []
				result.each { |row|
					model = Model::Tool.new
					model.tool_id = row['tool_id']
					model.name = row['name']
					tools.push(model)
				}
				tools
			end
      def insert_artobject(values_hash)
        values_array = []
        values_hash.each { |key, value|
          unless(value.nil? || key == :tags)
            values_array.push("#{key}='#{Mysql.quote(value)}'")
          end
        }
        query = <<-EOS
          INSERT INTO artobjects
          SET #{values_array.join(', ')}
        EOS
        connection { |conn|
          result = conn.query(query)
          artobject_id = conn.insert_id
          tags = values_hash[:tags]
          unless tags.nil? || tags.empty?
            tags.each { |tag|
              unless tag.empty?
                query = <<-EOS
                  INSERT INTO tags (name) VALUES('#{tag}')
                  ON DUPLICATE KEY UPDATE tag_id=LAST_INSERT_ID(tag_id), name=name
                EOS
                conn.query(query)
                tag_id = conn.insert_id
                query = <<-EOS
                  INSERT INTO tags_artobjects
                  SET tag_id = '#{tag_id}', artobject_id='#{artobject_id}'
                EOS
                conn.query(query)
              end
            }
          end
          artobject_id
        }
      end
			def insert_guest(user_values)
				values = [
					Time.now.strftime("%Y-%m-%d"),
				]
				[ 
					:name, :city, :country, :email, :messagetxt 
				].each { |key| 
					values.push(Mysql.escape_string(user_values[key].to_s))
				}
				query = <<-EOS
					INSERT INTO guestbook
					VALUES ('','#{values.join("','")}'); 
				EOS
				connection.query(query)
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
      def query_affected_rows(query)
				connection { |conn|
          conn.query(query)
          conn.affected_rows
        }
      end
			def remove_serie(serie_id)
				query = <<-EOS
					DELETE FROM series WHERE serie_id='#{serie_id}'
				EOS
        query_affected_rows(query)
			end
			def remove_tool(tool_id)
				query = <<-EOS
					DELETE FROM tools WHERE tool_id='#{tool_id}'
				EOS
        query_affected_rows(query)
			end
			def remove_material(material_id)
				query = <<-EOS
					DELETE FROM materials WHERE material_id='#{material_id}'
				EOS
        query_affected_rows(query)
			end
			def search_artobjects(search_pattern)
				series = search_serie(search_pattern)
				serie_artobjects = series.collect { |serie|
					serie.artobjects	
				}
				where = <<-EOS
					WHERE artobjects.title
						REGEXP "#{search_pattern}"
				EOS
				artobjects = load_artobjects(where)
				serie_artobjects.flatten.concat(artobjects)
			end
			def search_serie(search_pattern)
				where = <<-EOS
					WHERE series.name 
						REGEXP "#{search_pattern}"
				EOS
				load_series(where)
			end

      # Updates artobject with tags
      def update_artobject(artobject_id, update_hash)
        transaction do |conn|
          delete_artobject_statement = conn.prepare(<<~EOS.gsub(/\n/, ''))
            DELETE FROM tags_artobjects WHERE artobject_id = ?
          EOS
          delete_artobject_statement.execute(artobject_id)
          tags = update_hash[:tags]
          if tags && !tags.empty?
            add_tag_statement = conn.prepare(<<~EOS.gsub(/\n/, ''))
              INSERT INTO tags (name) VALUES(?) ON DUPLICATE KEY UPDATE
               tag_id = LAST_INSERT_ID(tag_id), name = name
            EOS
            tags.each { |tag|
              next if tag.empty?
              add_tag_statement.execute(tag)
              tag_id = conn.last_id
              add_tag_relation_statement = conn.prepare(<<~EOS.gsub(/\n/, ''))
                INSERT INTO tags_artobjects (tag_id, artobject_id)
                 VALUES (?, ?)
              EOS
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
          update_artobject_statement = conn.prepare(<<~EOS.gsub(/\n/, ''))
            UPDATE artobjects
             SET #{updated_attrs.join(', ')} WHERE artobject_id = ?
          EOS
          update_artobject_statement.execute(artobject_id)
          conn.affected_rows
        end
      end

			def update_currency(origin, target, rate)
				query = <<-EOS
					UPDATE currencies
					SET rate='#{rate}'
					WHERE origin='#{origin}' AND target='#{target}';
				EOS
        query_affected_rows(query)
			end
			def update_guest(guest_id, update_hash)
				update_array = []
				update_hash.each { |key, value|
					unless(value.nil? || key == :tags)
						if(key == :date_gb)
							date = value.split(".")
							update_array.push("date='#{date[2]}-#{date[1]}-#{date[0]}'")
						else
							update_array.push("#{key}='#{Mysql.quote(value)}'")
						end
					end
				}
				query = <<-EOS
					UPDATE guestbook
					SET #{update_array.join(', ')}
					WHERE guest_id='#{guest_id}'
				EOS
        query_affected_rows(query)
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

      def set_attributes(model, row)
        row.each { |key, value|
          method = key.to_s + '='
          model.send(method, value) if model.respond_to?(method)
        }
      end
    end
  end
end
