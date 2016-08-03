require 'state/predefine'
require 'state/_partial/art_object'
require 'state/_partial/admin_methods'
require 'state/_partial/redirect'
require 'state/admin/ajax'
require 'util/image_helper'

module DaVaz::State
  module Admin
    module ArtObjectMethods

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
          title artgroup_id serie_id tool_id material_id date country_id
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
            if tmp_image_path = @model.artobject.tmp_image_path
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
            hash.store(key, value)
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

    # @api ajax
    class AjaxAddElement < SBSM::State
      VOLATILE = true

      def init
        @select_name = @session.user_input(:select_name)
        select_value = @session.user_input(:select_value)
        @session.app.send("add_#@select_name", select_value)
        @model = OpenStruct.new
        @model.selection = @session.app.send("load_#{@select_name}s".intern)
        @model.selection.map { |sel|
          @model.selected = sel if sel.name == select_value
        }
      end

      def view
        DaVaz::View::AjaxDynSelect.new(
          "#{@select_name}_id", @model, @session, self)
      end
    end

    # @api ajax
    # @note responds to:
    #   /de/gallery/ajax_add_form/artobject_id/XXX/name/{serie|tool|material}
    class AjaxAddForm < SBSM::State
      VIEW     = DaVaz::View::AddFormComposite
      VOLATILE = true

      def init
        super
        @model = OpenStruct.new
        @model.artobject_id = @session.user_input(:artobject_id)
        # name = {serie|tool|material}
        @model.name = @session.user_input(:name)
      end
    end

    # @api ajax
    # @note responds to:
    #   /de/gallery/ajax_all_tags
    class AjaxAllTags < SBSM::State
      VIEW     = DaVaz::View::ShowAllTags
      VOLATILE = true

      def init
        @model = @session.app.load_tags
      end
    end

    # @api ajax
    class AjaxAllTagsLink < SBSM::State
      VIEW     = DaVaz::View::ShowAllTagsLink
      VOLATILE = true

      def init
        @model = []
      end
    end

    # @api ajax
    class AjaxRemoveElement < SBSM::State
      VOLATILE = true

      def add_error(select_name, selected_id)
        error = create_error(
          'e_not_good_for_removal', select_name, selected_id)
        @errors.store("#{@select_name}_id", error)
      end

      def init
        artobject_id = @session.user_input(:artobject_id)
        @select_name = @session.user_input(:select_name)
        selected_id  = @session.user_input(:selected_id)
        select_class = @select_name.split("_").first
        count = @session.app.send(
          "count_#{select_class}_artobjects".intern, selected_id).to_i
        if count > 1
          add_error(@select_name, selected_id)
          self
        elsif count == 1
          art_id = @session.send(
            "load_#{select_class}_artobject_id".intern, selected_id)
          if art_id == artobject_id
            @session.app.send("remove_#@select_name", selected_id)
          else
            add_error(@select_name, selected_id)
          end
        else
          @session.app.send("remove_#@select_name", selected_id)
        end
        @model = OpenStruct.new
        @model.artobject = @session.app.load_artobject(artobject_id)
        selected_id = @model.artobject.send("#{@select_name}_id".intern)
        @model.selection = @session.app.send("load_#{@select_name}s".intern)
        @model.selection.each { |sel|
          if(selected_id == sel.sid)
            @model.selected = sel
          end
        }
      end

      def view
        DaVaz::View::AjaxDynSelect.new(
          "#{@select_name}_id", @model, @session, self)
      end
    end

    # @api admin
    class ArtObject < ArtObject
      include AdminMethods

      VIEW = DaVaz::View::AdminArtObject

      def init
        super
        build_selections
        unless @model.artobject
          @model.artobjects = []
          @model.artobject  = DaVaz::Model::ArtObject.new
        end
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
end
