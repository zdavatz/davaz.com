require 'state/predefine'
require 'state/_partial/redirect'
require 'state/_partial/element'
require 'state/_partial/image'
require 'model/tag'
require 'model/art_object'
require 'view/_partial/art_object'
require 'util/image_helper'

module DaVaz::State
  class ArtObject < Global
    VIEW = DaVaz::View::ArtObject

    def init
      artobject_id = @session.user_input(:artobject_id)
      artgroup_id  = @session.user_input(:artgroup_id)
      serie_id     = @session.user_input(:serie_id)
      query        = @session.user_input(:search_query).to_s
      @model = OpenStruct.new
      if !query.empty?
        @model.artobjects = \
          @session.app.search_artobjects(query, artgroup_id)
      elsif serie_id
        @model.artobjects = @session.load_serie(serie_id).artobjects
      elsif artgroup_id
        @model.artobjects = @session.load_artgroup_artobjects(artgroup_id)
      else
        @model.artobjects = []
      end
      object = @model.artobjects.find { |artobject|
        artobject.artobject_id == artobject_id
      }
      if object.nil? && (object = @session.load_artobject(artobject_id))
        @model.artobjects.push(object)
      end
      @model.artobject = object
    end
  end

  # @api admin
  module AdminArtObjectMethods
    # Builds selection objects for artgroup serie tool material country
    # into model.
    # @return void
    def build_selections
      args = {aid: nil, sid: nil}
      args[:aid] = @model.artobject.artobject_id if @model.artobject

      %w(artgroup serie tool material country).map do |object|
        next unless @model.artobject
        args[:sid] = @model.artobject.send("#{object}_id")
        @model.send("select_#{object}=", build_selection(object, args))
      end
    end

    # @return state [SBSM::State]
    def update
      artobject_id = @session.user_input(:artobject_id) ||
        @model.artobject.artobject_id
      mandatory = %i{
        title artgroup_id serie_id tool_id material_id date country_id author
      }
      keys = %i{
        tags_to_s location form_language price serie_position size text url
      }.concat(mandatory)
      data = update_hash(keys, mandatory)
      unless error?
        if artobject_id
          @session.app.update_artobject(artobject_id, data)
        else
          insert_id = @session.app.insert_artobject(data)
          tmp_image_path = @model.artobject.tmp_image_path
          if insert_id && tmp_image_path
            image_path = @model.artobject.tmp_image_path
            DaVaz::Util::ImageHelper.store_tmp_image(image_path, insert_id)
          end
          artobject_id = insert_id
        end
        args = [
          [:artobject_id, artobject_id]
        ]
        search_query = @session.user_input(:search_query)
        if search_query
          args.push([:search_query, search_query])
        else
          args.push([:artgroup_id, @session.user_input(:artgroup_id)])
        end
        model = @session.lookandfeel.event_url(:gallery, :art_object, args)
        DaVaz::State::Redirect.new(@session, model)
      else
        reasign_attributes(data)
        build_selections
        self
      end
    end

    private

    # Builds single selection object.
    # this is helper function for `build_selections` method.
    #
    # @param object ['artgroup', 'serie', 'tool', 'material', 'country']
    # @param args [Hash{:aid => String, :sid => String}] ids from user_input
    # @see #build_selections
    # @return [OpenStruct] has #selection, #selcted and #artobject_id
    def build_selection(object, args)
      objects = (object =~ /ry$/) ? object[0..-2] + 'ies' : object + 's'
      select = OpenStruct.new
      select.artobject_id = args[:aid]
      select.selection    = @session.app.send("load_#{objects}".intern)
      select.selected     = select.selection.find { |sel|
        sel.send("#{object}_id") == args[:sid]
      }
      select.dup
    end

    def update_hash(keys, mandatory)
      hash = {}
      user_input(keys, mandatory).map { |key, value|
        if match = key.to_s.match(/(form_)(.*)/)
          hash.store(match[2].intern, value)
        elsif key == :tags_to_s
          unless value
            hash.store(:tags, [])
          else
            hash.store(:tags, value.split(','))
          end
        elsif key == :date
          hash.store(
            :date, "#{value.year}-#{value.month}-#{value.day}")
        else
          hash.store(key, value || '')
        end
      }
      hash
    end

    # Re:assigns attributes from artobject data
    #
    # @param data [Hash] updated attributes hash
    # @return void
    def reasign_attributes(data)
      tags = []
      data.map { |key, value|
        if key == :tags
          tag = DaVaz::Model::Tag.new
          tag.name = value
          tags.push(tag)
          next
        end
        @model.artobject.send((key.to_s + '=').intern, value)
      }
      @model.artobject.send('tags=', tags)
    end
  end

  # @api admin
  class AdminArtObject < ArtObject
    include AdminArtObjectMethods

    VIEW = DaVaz::View::AdminArtObject

    def init
      super
      unless @model.artobject
        @model.artobjects = []
        @model.artobject  = DaVaz::Model::ArtObject.new
      end
      build_selections
    end

    def ajax_upload_image
      AdminAjaxUploadImage.new(@session, @model)
    end

    def delete
      artobject_id = @model.artobject.artobject_id
      @session.app.delete_artobject(artobject_id)
      search
    end
  end
end
