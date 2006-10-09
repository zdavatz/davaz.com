#!/usr/bin/env ruby
# Selenium::DbManager -- davaz.com -- 27.09.2006 -- mhuggler@ywesee.com

require 'model/artgroup'
require 'model/artobject'
require 'model/country'
require 'model/guest'
require 'model/material'
require 'model/serie'
require 'model/tag'
require 'model/tool'
require 'util/lookandfeel'

module DAVAZ
	module Stub 
		class StubArtgroup < Model::Artgroup
			def initialize(id, name=nil)
				super()
				@artgroup_id = id 
				if(name.nil?)
					@name = "NameOfArtgroup#{id}"
				else
					@name = name
				end
				@shop_order = "ShopOrder of Artgroup #{id}"
			end
		end
		class StubArtobject < Model::ArtObject
			def initialize(id)
				super()
				@artobject_id = id 
				@artgroup = "ArtGroup of ArtObject #{id}"
				@date = "2#{id}-01-01"
				@dollar_price = (id.to_i*0.8).to_s
				@country = "Country of ArtObject #{id}"
				@country_id = "CH"
				@euro_price = (id.to_i*0.6).to_s
				@material = "Material of ArtObject #{id}"
				@material_id = "1"
				@price = id
				@size = "Size of ArtObject #{id}"
				@text = "Text of ArtObject #{id}"
				@title = "Title of ArtObject #{id}"
				@tool = "Tool of ArtObject #{id}"
				@tool_id = "1"
				@url = "Url of ArtObject #{id}"
			end
			def set_artgroup_id(artgroup_id)
				@artgroup_id = artgroup_id
			end
			def set_serie_id(serie_id)
				@serie = serie_id
			end
		end
		class StubCountry < Model::Country
			def initialize(id)
				super()
				@country_id = id
				@name = "Name of Country #{id}"
			end
		end
		class StubGuest < Model::Guest
			def initialize(id)
				super()
				@guest_id = id 
				@name = "Name of Guest #{id}"
				@email = "Email of Guest #{id}"
				@date = "2#{id}-01-01"
				@text = "Text of Guest #{id}"
				@city = "City of Guest #{id}"
				@country = "Country of Guest #{id}"
			end
		end
		class StubMaterial < Model::Material
			def initialize(id)
				super()
				@material_id = id
				@name = "Name of Material #{id}"
			end
		end
		class StubSerie < Model::Serie
			attr_accessor :artobjects
			def initialize(id)
				super()
				@serie_id = id
				@name = "Name of Serie #{id}"
			end
			def artobjects=(artobject_array)
				@artobjects = artobject_array
			end
		end
		class StubTag < Model::Tag
			def initialize(id)
				super()
				@tool_id = id
				@name = "Name of Tag #{id}"
			end
		end
		class StubTool < Model::Tool
			def initialize(id)
				super()
				@tool_id = id
				@name = "Name of Tool #{id}"
			end
		end
		
		class DbManager
			def initialize
				@countries = [
					StubCountry.new('CH'),
					StubCountry.new('D'),
					StubCountry.new('F'),
				]
				@guests = [ 
					StubGuest.new('1'),
				]
				@materials = [
					StubMaterial.new('1'),
					StubMaterial.new('2'),
					StubMaterial.new('3'),
				]
				@series = [
					StubSerie.new('ABC'),
					StubSerie.new('ABD'),
					StubSerie.new('ABE'),
				]
				@tools = [
					StubTool.new('1'),
					StubTool.new('2'),
					StubTool.new('3'),
				]
				artobject1 = StubArtobject.new('111')
				artobject1.set_artgroup_id('234') 
				artobject1.set_serie_id('ABC') 
				artobject2 = StubArtobject.new('112')
				artobject2.set_artgroup_id('234') 
				artobject2.set_serie_id('ABC') 
				artobject3 = StubArtobject.new('113')
				artobject3.set_artgroup_id('234') 
				artobject3.set_serie_id('ABD') 
				artobject4 = StubArtobject.new('114')
				artobject4.set_artgroup_id('235') 
				artobject4.set_serie_id('ABD') 
				artobject5 = StubArtobject.new('115')
				artobject5.set_artgroup_id('235') 
				artobject5.set_serie_id('ABE') 
				@artobjects = [
					artobject1, artobject2, artobject3, artobject4, artobject5
				]
				@artgroups = [
					StubArtgroup.new('234', 'movies'),
					StubArtgroup.new('235', 'drawings'),
				]
			end
			def count_artobjects(by, id)
				3
			end
			def delete_artobject(artobject_id)
				@artobjects.delete_if { |aobject| aobject.artobject_id == artobject_id}
				return 1
			end
			def insert_artobject(update_values)
				artobject6 = StubArtobject.new('116')
				artobject6.set_artgroup_id('235') 
				artobject6.set_serie_id('ABE') 
				update_values.each { |key, value|
					artobject6.send("#{key.to_s}=", value)
				}
				artobject6.send("tags=", [ StubTag.new(update_values[:tags]) ])
				@artobjects.push(artobject6)
				'116'
			end
			def insert_guest(user_values)
				guest = StubGuest.new('2')
				guest.name = user_values[:name]
				guest.city = user_values[:city]
				guest.country = user_values[:country]
				guest.email = user_values[:email]
				guest.text = user_values[:messagetxt]
				@guests.unshift(guest)
			end
			def load_artgroups(order_by=nil)
				@artgroups
			end
			def load_artobject(artobject_id, select_by=nil)
				aobjects = @artobjects.select { |aobject| 
					aobject.artobject_id == artobject_id 
				}
				aobjects.first
			end
			def load_artobject_ids(artgroup)
				[]
			end
			def load_artobjects_by_artgroup(artgroup_id)
				@artobjects
			end
			def load_countries
				@countries
			end
			def load_guests
				@guests
			end
			def load_materials
				@materials
			end
			def load_movies
				@artobjects
			end
			def load_oneliner(location)
				[]
			end
			def load_serie(serie_id, select_by)
				serie = @series.select { |serie| serie.serie_id == serie_id }.first
				serie.artobjects = @artobjects.select { |aobject| 
					aobject.serie == serie_id 
				}
				serie
			end
			def load_serie_artobjects(serie_id, select_by)
				case serie_id
				when 'Site News'
					@artobjects.select { |aobject| aobject.serie == 'ABC' }
				when 'Site Links'
					@artobjects.select { |aobject| aobject.serie == 'ABD' }
				when 'Site His Life English'
					@artobjects.select { |aobject| aobject.serie == 'ABE' }
				when 'Site His Life Chinese'
					@artobjects.select { |aobject| aobject.serie == 'ABC' }
				when 'Site His Life Hungarian'
					@artobjects.select { |aobject| aobject.serie == 'ABD' }
				when 'Site His Work'
					@artobjects.select { |aobject| aobject.serie == 'ABE' }
				when 'Site His Inspiration'
					@artobjects.select { |aobject| aobject.serie == 'ABC' }
				when 'Site His Family'
					@artobjects.select { |aobject| aobject.serie == 'ABD' }
				when 'Site The Family'
					@artobjects.select { |aobject| aobject.serie == 'ABE' }
				when 'Site Articles'
					@artobjects.select { |aobject| aobject.serie == 'ABC' }
				when 'Site Lectures'
					@artobjects.select { |aobject| aobject.serie == 'ABD' }
				when 'Site Exhibitions'
					@artobjects.select { |aobject| aobject.serie == 'ABE' }
				else
					[]
				end
			end
			def load_serie_id(serie_name)
				'CCC'
			end
			def load_series(where, load_artobjects=true)
				@series
			end
			def load_series_by_artgroup(artgroup)
				@series
			end
			def load_shop_item(artobject_id)
				@artobjects.select { |aobject| 
					aobject.artobject_id == artobject_id
				}.first
			end
			def load_shop_items
				@artobjects
			end
			def load_tag_artobjects(tag)
				[]
			end
			def load_tools
				@tools
			end
			def search_artobjects(query)
				@artobjects.select { |aobject| aobject.serie == query}
			end
			def update_artobject(artobject_id, update_values)
				artobject = @artobjects.select { |aobject| 
					aobject.artobject_id == artobject_id
				}.first
				update_values.each { |key, value|
					if(key==:tags)
						artobject.send("#{key.to_s}=", [ StubTag.new(value) ])
					elsif(key==:url)
						artobject.send("#{key.to_s}=", value)
					else
						artobject.send("#{key.to_s}=", value)
					end
				}
			end
		end
	end
end
