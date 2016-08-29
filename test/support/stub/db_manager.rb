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
require 'util/lookandfeel'

module DaVaz::Stub
  class StubArtgroup < DaVaz::Model::ArtGroup
    def initialize(id, name=nil)
      super()
      @artgroup_id = id
      @name = name || "NameOfArtgroup#{id}"
      @shop_order = "ShopOrder of Artgroup #{id}"
    end
  end

  class StubArtObject < DaVaz::Model::ArtObject
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
      @serie_position = id
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

    def set_links(links)
      @links = links
    end

    def set_serie_id(serie_id)
      @serie_id = serie_id
    end

    def set_tags(tags_arr)
      @tags = tags_arr
    end
  end

  class EmptyStubArtObject < DaVaz::Model::ArtObject
    def initialize(id)
      super()
      @artobject_id = id
      @date = "2#{id}-01-01"
    end

    def set_artgroup_id(artgroup_id)
      @artgroup_id = artgroup_id
    end

    def set_serie_id(serie_id)
      @serie_id = serie_id
    end

    def set_tags(tags_arr)
      @tags = tags_arr
    end
  end

  class StubCountry < DaVaz::Model::Country
    def initialize(id)
      super()
      @country_id = id
      @name = "Name of Country #{id}"
    end
  end

  class StubGuest < DaVaz::Model::Guest
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

  class StubLink < DaVaz::Model::Link
    def initialize(link_id, word, aid)
      super()
      @link_id = link_id
      @word = word
      @artobject_id = aid
    end

    def set_artobjects(artobjects)
      @artobjects = artobjects
    end
  end

  class StubMaterial < DaVaz::Model::Material
    def initialize(id)
      super()
      @material_id = id
      @name = "Name of Material #{id}"
    end
  end

  class StubOneLiner < DaVaz::Model::OneLiner
    def initialize(id)
      super()
      @oneliner_id = id
      @text  = "This is the Text of\n the OneLiner with id #{id}"
      @location  = 'hisfamily'
      @color = 'gray'
      @size = '20'
      @active = '1'
    end
  end

  class StubSerie < DaVaz::Model::Serie
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

  class StubTag < DaVaz::Model::Tag
    def initialize(name)
      super()
      @tag_id = Time.now.to_i
      @name = name
    end
  end

  class StubTool < DaVaz::Model::Tool
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
        StubGuest.new('2'),
        StubGuest.new('3'),
      ]
      @materials = [
        StubMaterial.new('1'),
        StubMaterial.new('2'),
        StubMaterial.new('3'),
      ]
      @oneliner = [
        StubOneLiner.new('1'),
        StubOneLiner.new('2'),
        StubOneLiner.new('3'),
      ]
      @series = [
        StubSerie.new('ABC'),
        StubSerie.new('ABD'),
        StubSerie.new('ABE'),
      ]
      @tags = [
        StubTag.new('Name of Tag 1'),
        StubTag.new('Name of Tag 2'),
        StubTag.new('Name of Tag 3'),
      ]
      @tools = [
        StubTool.new('1'),
        StubTool.new('2'),
        StubTool.new('3'),
      ]
      artobject1 = StubArtObject.new('111')
      artobject1.set_artgroup_id('234')
      artobject1.set_serie_id('ABC')
      artobject1.set_tags([StubTag.new('hislife_show')])

      artobject2 = StubArtObject.new('112')
      artobject2.set_artgroup_id('234')
      artobject2.set_serie_id('ABC')
      artobject2.set_tags([ StubTag.new('hislife_show') ])

      artobject3 = StubArtObject.new('113')
      artobject3.set_artgroup_id('234')
      artobject3.set_serie_id('ABD')

      artobject4 = StubArtObject.new('114')
      artobject4.set_artgroup_id('235')
      artobject4.set_serie_id('ABD')

      artobject5 = StubArtObject.new('115')
      artobject5.set_artgroup_id('235')
      artobject5.set_serie_id('ABE')
      artobject5.set_tags([StubTag.new('hisfamily_show')])

      link1 = StubLink.new('1', 'Title', '115')
      link1.set_artobjects([artobject1])

      link2 = StubLink.new('2', 'Text', '115') # link
      link2.set_artobjects([artobject2, artobject3, artobject5])

      link3 = StubLink.new('3', 'Text', '115') # tooltip
      link3.set_artobjects([artobject4])

      link4 = StubLink.new('4', 'Title', '115')
      link4.set_artobjects([artobject1, artobject5])

      artobject1.set_links([link1])
      artobject2.set_links([link2])
      artobject3.set_links([link2])
      artobject4.set_links([link3])
      artobject5.set_links([link1, link2])

      @artobjects = [
        artobject1, artobject2, artobject3, artobject4, artobject5
      ]
      @artgroups = [
        StubArtgroup.new('234', 'movies'),
        StubArtgroup.new('235', 'drawings'),
      ]
    end

    def add_material(material_name)
      material = StubMaterial.new("4")
      material.name = material_name
      @materials.push(material)
    end

    def add_serie(serie_name)
      serie = StubSerie.new("ABF")
      serie.name = serie_name
      @series.push(serie)
    end

    def add_tool(tool_name)
      tool = StubTool.new("4")
      tool.name = tool_name
      @tools.push(tool)
    end

    def count_artobjects(by, id)
      case by
      when 'serie_id'
        serie = @series.select { |serie| serie.serie_id == id }.first
        serie ? serie.artobjects.size : 0
      when 'tool_id'
        @artobjects.select { |aobject|
          aobject.tool_id == id
        }.size
      when 'material_id'
        @artobjects.select { |aobject|
          aobject.material_id == id
        }.size
      else
        return 3
      end
    end

    def delete_artobject(artobject_id)
      @artobjects.delete_if { |aobject| aobject.artobject_id == artobject_id}
      return 1
    end

    def delete_guest(guest_id)
      @guests.delete_if { |guest| guest.guest_id == guest_id}
      return 1
    end

    def insert_artobject(update_values)
      artobject6 = EmptyStubArtObject.new('116')
      update_values.each { |key, value|
        if(key == :artgroup_id)
          artgroup = @artgroups.select { |agroup|
            agroup.artgroup_id == value
          }.first
          artobject6.send("artgroup=", artgroup.name)
          artobject6.send("artgroup_id=", value)
        elsif(key == :serie_id)
          serie = @series.select { |object|
            object.serie_id == value
          }.first
          artobject6.send("serie=", serie.name) if serie
          artobject6.send("serie_id=", value)
        elsif(key == :material_id)
          material = @materials.select { |object|
            object.material_id == value
          }.first
          artobject6.send("material=", material.name) if material
          artobject6.send("material_id=", value)
        elsif(key == :tool_id)
          tool = @tools.select { |object|
            object.tool_id == value
          }.first
          artobject6.send("tool=", tool.name) if tool
          artobject6.send("tool_id=", value)
        elsif(key == :date_ch)
          date = value.split(".")
          artobject6.send("date=", "#{date[2]}-#{date[1]}-#{date[0]}")
        else
          artobject6.send("#{key.to_s}=", value)
        end
      }
      unless(update_values[:tags].nil?)
        artobject6.send("tags=", [ StubTag.new(update_values[:tags]) ])
      end
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
      if(select_by=='title')
        @artobjects.first
      else
        return aobjects.first
      end
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

    def load_element_artobject_id(element, element_id)
      aobjects = @artobjects.select { |aobject|
        aobject.send(element.intern) == element_id
      }
      aobjects.first.artobject_id
    end

    def load_guest(guest_id)
      @guests.select { |guest| guest.guest_id == guest_id }.first
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
      @oneliner
    end

    def load_serie(serie_id, select_by)
      serie = @series.select { |serie| serie.serie_id == serie_id }.first
      serie.artobjects = @artobjects.select { |aobject|
        aobject.serie_id == serie_id
      }
      serie
    end

    def load_serie_artobjects(serie_id, select_by)
      case serie_id
      when 'Site News'
        @artobjects.select { |aobject| aobject.serie_id == 'ABC' }
      when 'Site Links'
        @artobjects.select { |aobject| aobject.serie_id == 'ABD' }
      when 'Site His Life English'
        @artobjects.select { |aobject| aobject.serie_id == 'ABE' }
      when 'Site His Life Chinese'
        @artobjects.select { |aobject| aobject.serie_id == 'ABC' }
      when 'Site His Life Hungarian'
        @artobjects.select { |aobject| aobject.serie_id == 'ABD' }
      when 'Site His Work'
        @artobjects.select { |aobject| aobject.serie_id == 'ABE' }
      when 'Site His Inspiration'
        @artobjects.select { |aobject| aobject.serie_id == 'ABC' }
      when 'Site His Family'
        @artobjects.select { |aobject| aobject.serie_id == 'ABD' }
      when 'Site The Family'
        @artobjects.select { |aobject| aobject.serie_id == 'ABE' }
      when 'Site Articles'
        @artobjects.select { |aobject| aobject.serie_id == 'ABC' }
      when 'Site Lectures'
        @artobjects.select { |aobject| aobject.serie_id == 'ABD' }
      when 'Site Exhibitions'
        @artobjects.select { |aobject| aobject.serie_id == 'ABE' }
      else
        []
      end
    end

    def load_serie_id(serie_name)
      'CCC'
    end

    def load_series(where, load_artobjects=true)
      @series.each { |serie|
        serie.artobjects = @artobjects.select { |aobject|
          aobject.serie_id == serie.serie_id
        }
      }
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

    def load_tags
      @tags
    end

    def load_tag_artobjects(tag_name)
      aobjects = []
      @artobjects.each { |aobject|
        aobject.tags.each { |tag|
          if(tag.name == tag_name)
            aobjects.push(aobject)
          end
        }
      }
      aobjects
    end

    def load_tools
      @tools
    end

    def remove_material(material_id)
      @materials.delete_if { |material| material.material_id == material_id }
      @materials
    end

    def remove_serie(serie_id)
      @series.delete_if { |serie| serie.serie_id == serie_id }
      @series
    end

    def remove_tool(tool_id)
      @tools.delete_if { |tool| tool.tool_id == tool_id }
      @tools
    end

    def search_artobjects(query)
      @artobjects.select { |aobject| aobject.serie_id == query}
    end

    def update_artobject(artobject_id, update_values)
      artobject = @artobjects.select { |aobject|
        aobject.artobject_id == artobject_id
      }.first
      update_values.each { |key, value|
        if(key==:tags)
          arr = []
          value.each { |tag_name|
            arr.push(StubTag.new(tag_name)) unless tag_name == ""
          }
          artobject.send("tags=", arr)
        elsif(key==:url)
          artobject.send("#{key.to_s}=", value)
        elsif(key==:date_ch)
          date = value.split(".")
          artobject.send("date=", "#{date[2]}-#{date[1]}-#{date[0]}")
        else
          artobject.send("#{key.to_s}=", value)
        end
      }
    end

    def update_guest(guest_id, update_values)
      guest = @guests.select { |guest_object|
        guest_object.guest_id == guest_id
      }.first
      update_values.each { |key, value|
        if(key==:date_gb)
          date = value.split(".")
          guest.send("date=", "#{date[2]}-#{date[1]}-#{date[0]}")
        else
          guest.send("#{key.to_s}=", value)
        end
      }
    end
  end
end
