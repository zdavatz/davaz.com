#!/usr/bin/env ruby
# Selenium::DbManager -- davaz.com -- 27.09.2006 -- mhuggler@ywesee.com

require 'model/artobject'
require 'model/serie'

module DAVAZ
	module Stub 
		class StubArtobject < Model::ArtObject
			def initialize(id, serie)
				super()
				@artobject_id = id 
				@title = "Title of ArtObject #{id}"
				@date = "2#{id}-01-01"
				@tool = "Tool of ArtObject #{id}"
				@material = "Material of ArtObject #{id}"
				@size = "Size of ArtObject #{id}"
				@country = "Country of ArtObject #{id}"
				@serie = serie.name
				@artgroup = "ArtGroup of ArtObject #{id}"
			end
		end
		class StubSerie < Model::Serie
			attr_accessor :artobjects
			def initialize(id)
				super()
				@serie_id = id
				@name = "Name of Serie #{id}"
			end
		end
		class DbManager
			def load_artgroups
				[]
			end
			def load_oneliner(location)
				[]
			end
			def load_serie(serie_id, select_by)
				serie = StubSerie.new(serie_id)
				serie.artobjects.push(StubArtobject.new('123', serie))
				serie.artobjects.push(StubArtobject.new('124', serie))
				serie.artobjects.push(StubArtobject.new('125', serie))
				serie
			end
			def load_series(where, load_artobjects=true)
				[
					StubSerie.new('ABC'),
					StubSerie.new('ABD'),
				]
			end
		end
	end
end
