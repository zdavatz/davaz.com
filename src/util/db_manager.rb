#!/usr/bin/env ruby
# Util::DbClient -- davaz.com -- 27.07.2005 -- mhuggler@ywesee.com

require 'ftools'
require 'date'
require 'mysql'
require 'yaml'
require 'model/artgroup'
require 'model/displayelement'
require 'model/guest'
require 'model/link'
require 'model/oneliner'
require 'model/serie'
require 'model/slideshow_item'

module DAVAZ
	module Util
		class DbManager
			DB_CONNECTION_DATA = File.expand_path('../../etc/db_connection_data.yml', File.dirname(__FILE__))
			def initialize
				@connection = connect
				@connection.reconnect = true
			end
			def connect
				db_data = YAML.load(File.read(DB_CONNECTION_DATA))
				Mysql.new(db_data['host'], db_data['user'], db_data['password'], db_data['db'])
			end
			def connection
				@connection ||= connect
			end
			def load_artgroups(order_by='artgroup_id')
				query = <<-EOS
					SELECT *
					FROM artgroups
					ORDER BY #{order_by} ASC;
				EOS
				result = connection.query(query)
				artgroups = []
				result.each_hash { |key, value| 
					model = DAVAZ::Model::Artgroup.new
					key.each { |col_name, col_value|
						model.send(col_name.to_s + '=', col_value)
					}
					artgroups.push(model)
				}		
				artgroups
			end
			def load_artobject(artobject_id)
				query = <<-EOS
					SELECT artobjects.*, 
						artobjects_displayelements.display_id AS display_id,
						artgroups.name AS artgroup,
						materials.name AS material,
						tools.name AS tool,
						series.name AS serie,
						countries.name AS country
					FROM artobjects
					LEFT OUTER JOIN artobjects_displayelements
						ON artobjects.artobject_id = artobjects_displayelements.artobject_id
					LEFT OUTER JOIN artgroups
						ON artobjects.artgroup_id = artgroups.artgroup_id
					LEFT OUTER JOIN materials 
						ON artobjects.material_id = materials.material_id
					LEFT OUTER JOIN tools 
						ON artobjects.tool_id = tools.tool_id
					LEFT OUTER JOIN series 
						ON artobjects.serie_id = series.serie_id
					LEFT OUTER JOIN countries 
						ON artobjects.country_id = countries.country_id
					WHERE artobjects.artobject_id='#{artobject_id}';
				EOS
				result = connection.query(query)
				artobject = nil
				result.each_hash { |key, value| 
					model = DAVAZ::Model::ArtObject.new
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
					artobject = model
				}
				artobject
			end
			def load_artobjects(artgroup_id)
				if(artgroup_id.nil?)
					by_artgroup = ""
				else
					by_artgroup = "WHERE artobjects.artgroup_id='#{artgroup_id}'"
				end
				query = <<-EOS
					SELECT artobjects.*, 
						artobjects_displayelements.display_id AS display_id,
						artgroups.name AS artgroup,
						materials.name AS material,
						tools.name AS tool,
						series.name AS serie,
						countries.name AS country
					FROM artobjects
					LEFT OUTER JOIN artobjects_displayelements
						ON artobjects.artobject_id = artobjects_displayelements.artobject_id
					LEFT OUTER JOIN artgroups
						ON artobjects.artgroup_id = artgroups.artgroup_id
					LEFT OUTER JOIN materials 
						ON artobjects.material_id = materials.material_id
					LEFT OUTER JOIN tools 
						ON artobjects.tool_id = tools.tool_id
					LEFT OUTER JOIN series 
						ON artobjects.serie_id = series.serie_id
					LEFT OUTER JOIN countries 
						ON artobjects.country_id = countries.country_id
					#{by_artgroup}
					ORDER BY artobjects.title DESC
				EOS
				result = connection.query(query)
				create_model_array(DAVAZ::Model::ArtObject, result)
			end
			def load_country(id)
			end
			def load_currency_rates
				query = <<-EOS
					SELECT * 
					FROM currencies
				EOS
				result = connection.query(query)
				rates = {}
				result.each_hash { |key, value|
					rates.store(key['target'], key['rate'].to_f)
				}
				rates
			end
			def load_exhibitions
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
			def load_material(id)
			end
			def load_news
				query = <<-EOS
					SELECT displayelements.*,
						displayelements_displayelements.to_display_id AS to_display_id
					FROM displayelements
					LEFT OUTER JOIN displayelements_displayelements
						USING (display_id)
					WHERE location='news'
					ORDER BY date ASC;
				EOS
				result = connection.query(query)
				create_model_array(DAVAZ::Model::DisplayElement, result)
			end
			def load_oneliner(location)
				sql = <<-SQL
					SELECT * FROM oneliner WHERE location='#{location}'; 
				SQL
				result = connection.query(sql)
				create_model_array(DAVAZ::Model::OneLiner, result) 
			end
			def load_serie(serie_id)
				sql = <<-SQL
					SELECT artobjects.*,
						artobjects_displayelements.display_id AS display_id,
						displayelements.text AS comment
					FROM artobjects
					LEFT JOIN artobjects_displayelements USING (artobject_id)
					LEFT JOIN displayelements USING (display_id)
					WHERE serie_id='#{serie_id}'
					ORDER BY serie_nr DESC
				SQL
				result = connection.query(sql)
				create_model_array(Model::ArtObject, result)
			end
			def load_series
				sql = <<-SQL
					SELECT * 
					FROM series	
				SQL
				result = connection.query(sql)
				array = [] 
				result.each_hash { |key, value|
					model = DAVAZ::Model::Serie.new
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
					array.push(model)
				}
				array
			end
			def load_series_by_artgroup(artgroup_id)
				sql = <<-SQL
					SELECT series.serie_id,series.name FROM artobjects
					JOIN series USING (serie_id)
					WHERE artobjects.artgroup_id='#{artgroup_id}' 
				SQL
				result = connection.query(sql)
				create_unique_model_array(Model::Serie, result, 'serie_id')
			end
=begin
			def load_serie_objects(table_class, artgroup_id, serie_id)
				sql = <<-SQL
					SELECT artobjects.title, artobjects_displayelements.*, 
					displayelements.display_id, displayelements.text AS comment
					FROM artobjects
					LEFT JOIN artobjects_displayelements USING (artobject_id)
					LEFT JOIN displayelements USING (display_id) 
					WHERE serie_id='#{serie_id}'
					AND artgroup_id='#{artgroup_id}'
					ORDER BY serie_nr DESC
				SQL
				result = connection.query(sql)
				create_model_array(table_class, result)
			end
=end
			def load_slideshow(title)
				sql = <<-SQL
					SELECT 
						slideshow_items.display_id AS display_id,
						slideshow_items.position, 
						displayelements.title AS title 
					FROM slideshow_items
					LEFT JOIN displayelements USING (display_id)
					WHERE slideshow_items.slideshow='#{title}'
					ORDER BY slideshow_items.position;
				SQL
				result = connection.query(sql)
				array = [] 
				result.each_hash { |key, value|
					model = DAVAZ::Model::SlideShowItem.new
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
					array.push(model) unless model.display_id == '0'
				}
				array
			end
			def load_shop_items()
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
				result.each_hash { |key, value| 
					artobject = DAVAZ::Model::ArtObject.new 
					key.each { |column_name, column_value| 
						artobject.send(column_name.to_s + '=', column_value)
					}
					rates = load_currency_rates
					artobject.dollar_price = (rates['USD'] * artobject.price.to_i).round
					artobject.euro_price = (rates['EURO'] * artobject.price.to_i).round
					items.push(artobject)
				}
				items
			end
			def load_shop_artobject(artobject_id)
				query = <<-EOS
					SELECT artobjects.*, 
					artobjects_displayelements.display_id AS display_id
					FROM artobjects
					LEFT OUTER JOIN artobjects_displayelements
					ON artobjects.artobject_id = artobjects_displayelements.artobject_id
					WHERE artobjects.artobject_id='#{artobject_id}';
				EOS
				result = connection.query(query)
				item = nil
				result.each_hash { |key, value| 
					artobject = DAVAZ::Model::ArtObject.new 
					key.each { |column_name, column_value| 
						artobject.send(column_name.to_s + '=', column_value)
					}
					rates = load_currency_rates
					artobject.dollar_price = (rates['USD'] * artobject.price.to_i).round
					artobject.euro_price = (rates['EURO'] * artobject.price.to_i).round
					item = artobject
				}
				item
			end
			def load_shop_item(id)
			end
			def load_tool(id)
			end
			def load_displayelements(type, location, order="display_id", order_direction="ASC")
				where = []
				where.push("displayelements.type='#{type}'") unless type.nil?
				where.push("displayelements.location='#{location}'") unless location.nil?
				query = <<-EOS
					SELECT displayelements.*, links.word, links.link_id,
					links.href, links.type, 
					links_displayelements.display_id AS link_display_id
					FROM displayelements 
					LEFT OUTER JOIN links 
					ON displayelements.display_id = links.display_id
					LEFT OUTER JOIN links_displayelements
					ON links_displayelements.link_id = links.link_id
					WHERE #{where.join(" AND ")}
					ORDER BY #{order} #{order_direction}
				EOS
				result = connection.query(query)
				array = compose_displayelements_result(result)
			end
			def load_displayelement(select_by, value)
				query = <<-EOS
					SELECT displayelements.*,links.word, links.link_id,
					links.href, links.type
					FROM displayelements 
					LEFT OUTER JOIN links 
					ON displayelements.display_id = links.display_id
					WHERE displayelements.#{select_by}='#{value}'
					LIMIT 1 
				EOS
				result = connection.query(query)
				compose_displayelements_result(result).first
			end
			def compose_displayelements_result(result)
				elements = []
				element = nil
				last_id = nil
				result.each_hash { |row|
					display_id = row.delete('display_id')
					if(display_id != last_id)
						element = DAVAZ::Model::DisplayElement.new
						row.each { |key, value|
							method = "#{key}=".to_sym
							if(element.respond_to?(method))
								element.send(method, value)
							end
						}
						element.send(:display_id=, display_id)
						elements.push(element)
						last_id = display_id
					end
					link = DAVAZ::Model::Link.new
					row.each { |key, value|
						method = "#{key}=".to_sym
						if(link.respond_to?(method))
							link.send(method, value) unless value.nil?
						end
					}
					old_link = element.links.select { |old_lnk| 
						old_lnk.link_id == link.link_id	
					}
					to_element = load_displayelement('display_id', 
						row['link_display_id'])
					if(old_link.empty?)
						link.add_displayelement(to_element)
						element.links.push(link) unless link.word.nil?
					else
						old_link.first.add_displayelement(to_element)
					end
				}
				elements
			end
			def load_link_displayelement(link_id)
				query = <<-EOS
					SELECT displayelements.*, links.link_id
					FROM links 
					JOIN links_displayelements USING (link_id)
					JOIN displayelements USING (display_id)
					WHERE links.link_id='#{link_id}'
				EOS
				result = connection.query(query) 
				elements = []
				result.each_hash { |row|
					element = DAVAZ::Model::DisplayElement.new
					row.each { |key, value|
						method = "#{key}=".to_sym
						if(element.respond_to?(method))
							element.send(method, value)
						end
					}
					elements.push(element)
				}
				elements.first
			end
			def load_link_displayelements(link_id)
				query = <<-EOS
					SELECT displayelements.*, links.link_id
					FROM links 
					JOIN links_displayelements USING (link_id)
					JOIN displayelements USING (display_id)
					WHERE links.link_id='#{link_id}'
				EOS
				result = connection.query(query) 
				elements = []
				result.each_hash { |row|
					element = DAVAZ::Model::DisplayElement.new
					row.each { |key, value|
						method = "#{key}=".to_sym
						if(element.respond_to?(method))
							element.send(method, value)
						end
					}
					elements.push(element)
				}
				elements
			end
			def load_movie(id)
			end
			def insert_guest(user_values)
				values = [
					Time.now.strftime("%Y-%m-%d"),
				]
				[ 
					:name, :surname, :city, :country, :email, :messagetxt 
				].each { |key| 
					values.push(Mysql.escape_string(user_values[key])) 
				}
				query = <<-EOS
					INSERT INTO guestbook
					VALUES ('','#{values.join("','")}'); 
				EOS
				connection.query(query)
			end
			def create_model_array(model_class, result)
				array = []
				result.each_hash { |key, value| 
					model = model_class.new
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
					array.push(model)
				}
				array
			end
			def create_unique_model_array(model_class, result, key)
				array = []
				key_array = []
				result.each_hash { |key, value| 
					model = model_class.new
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
					unless(key_array.include?(key))
						array.push(model)
						key_array.push(key)
					end
				}
				array
			end
			def create_model_hash(model_class, result, hsh_key)
				hash = {}	
				result.each_hash { |key, value| 
					model = model_class.new	
					key.each { |column_name, column_value| 
						model.send(column_name.to_s + '=', column_value)
					}
					hash.store(model.send(hsh_key), model)
				}
				hash
			end
			def search_artobjects(search_pattern, artgroup_id)
				if(artgroup_id.nil?)
					artgroup = ""
				else
					artgroup = "AND artobjects.artgroup_id='#{artgroup_id}'"
				end
				query = <<-EOS
					SELECT artobjects.*, 
						artobjects_displayelements.display_id AS display_id,
						artgroups.name AS artgroup,
						materials.name AS material,
						tools.name AS tool,
						series.name AS serie,
						countries.name AS country
					FROM artobjects
					LEFT OUTER JOIN artgroups USING (artgroup_id)
					LEFT OUTER JOIN artobjects_displayelements
						ON artobjects.artobject_id = artobjects_displayelements.artobject_id
					LEFT OUTER JOIN materials 
						ON artobjects.material_id = materials.material_id
					LEFT OUTER JOIN tools 
						ON artobjects.tool_id = tools.tool_id
					LEFT OUTER JOIN series 
						ON artobjects.serie_id = series.serie_id
					LEFT OUTER JOIN countries 
						ON artobjects.country_id = countries.country_id
					WHERE artobjects.title
						REGEXP "#{search_pattern}"
						#{artgroup}
					OR series.name
						REGEXP "#{search_pattern}"
						#{artgroup}
				EOS
				result = connection.query(query)
				create_model_array(DAVAZ::Model::ArtObject, result)
			end
			def update_currency(origin, target, rate)
				query = <<-EOS
					UPDATE currencies
					SET rate='#{rate}'
					WHERE origin='#{origin}' AND target='#{target}';
				EOS
				result = connection.query(query)
				connection.affected_rows
			end
		end
	end
end
