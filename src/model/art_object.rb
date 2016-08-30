require 'util/image_helper'

module DaVaz::Model
  class ArtObject
    attr_reader :links, :tags
    attr_accessor *%i{
      dollar_price euro_price count
      artobject_id
      tool_id tool
      material_id material
      artgroup_id artgroup
      country_id country
      serie_id serie
      serie_position
      size location
      language title public
      date movie_type url
      text author charset
      price
      tmp_image_path
      wordpress_url
    }

    def initialize
      @links = []
      @tags  = []
    end

    def artcode
      date_value = begin
        unless date.is_a?(Date)
          Date.parse(date).year
        else
          date.year
        end
      rescue ArgumentError, NoMethodError
        '0000'
      end
      components = [
        artgroup_id,
        tool_id.to_s.rjust(2, '0'),
        material_id.to_s.rjust(2, '0'),
        '-',
        country_id.to_s.ljust(3, '_'),
        date_value,
        '-',
        serie_id,
        serie_position.rjust(4, '0'),
      ]
      components.join
    end

    def artobject_id
      @artobject_id || nil
    end

    def artgroup_id
      @artgroup_id || ""
    end

    def author
      @author || ""
    end

    def charset
      @charset || ""
    end

    def country_id
      @country_id || ""
    end

    def date
      @date || '00-00-0000'
    end

    def date_ch
      begin
        unless @date.is_a?(Date)
          Date.parse(@date)
        else
          @date
        end
      rescue ArgumentError, TypeError
        Date.today
      end.strftime('%d.%m.%Y')
    end

    def image_string_io
      @image_string_io || nil
    end

    def is_url?
      !url.empty? && title.empty? && text.empty?
    end

    def language
      @language || ""
    end

    def location
      @location || ""
    end

    def material_id
      @material_id || ""
    end

    def movie_type
      @movie_type || ""
    end

    def public
      @public || ""
    end

    def price
      @price || ""
    end

    def tmp_image_url
      rel = @tmp_image_path.dup
      rel.slice!(DaVaz.config.document_root)
      rel
    end

    def size
      @size || ""
    end

    def serie_id
      @serie_id || ""
    end

    def serie_position
      @serie_position || ""
    end

    def tags_to_s
      array = tags.collect { |tag| tag.name }
      array.join(',')
    end

    def tags=(tags)
      @tags = tags
    end

    def text
      @text || ""
    end

    def title
      @title || ""
    end

    def tool_id
      @tool_id || ""
    end

    def tool
      @tool || ""
    end

    def url
      @url || ""
    end
  end
end
