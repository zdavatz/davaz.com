require 'rmagick'
require 'sbsm/state'
require 'state/works/global'
require 'state/_partial/art_object'
require 'state/_partial/redirect'
require 'view/works/shorts'
require 'view/_partial/art_object'
require 'view/_partial/image'

module DaVaz::State
  module Works

    # @api ajax
    class AjaxShortGallery < SBSM::State
      VIEW     = DaVaz::View::ShortsArtObjectComposite
      VOLATILE = true

      def init
        artobject_id = @session.user_input(:artobject_id)
        @model = OpenStruct.new
        @model.artobjects = @session.load_shorts
        @model.artobject  = @model.artobjects.find { |obj|
          obj.artobject_id.to_s == artobject_id
        }
      end
    end

    # @api admin
    # @api ajax
    class AdminAjaxShortGallery < AjaxShortGallery
      include AdminArtObjectMethods

      VIEW = DaVaz::View::AdminShortsArtObjectComposite

      def init
        super
        build_selections
      end
    end

    # @api admin
    # @api ajax
    class AdminAjaxUploadImageShort < SBSM::State
      include Magick

      VIEW     = DaVaz::View::AdminImageDiv
      VOLATILE = true

      def init
        @model = OpenStruct.new
        string_io = @session.user_input(:image_file)
        artobject_id = @session.user_input(:artobject_id)
        if string_io && artobject_id
          DaVaz::Util::ImageHelper.store_upload_image(
            string_io, artobject_id)
          @model.artobject = @session.app.load_artobject(artobject_id)
        # no 'else' => src/state/_partial/art_object handles new artobjects
        end
      end
    end

    class Shorts < Global
      VIEW = DaVaz::View::Works::Shorts

      def init
        @model = @session.load_shorts()
      end
    end

    # @api admin
    class AdminShorts < Global
      VIEW = DaVaz::View::Works::AdminShorts

      def init
        @model = @session.load_shorts()
      end

      def ajax_upload_image
        AdminAjaxUploadImageShort.new(@session, @model)
      end

      def delete
        artobject_id = @session.user_input(:artobject_id)
        @session.app.delete_artobject(artobject_id)
        model = @session.lookandfeel.event_url(:works, :shorts)
        DaVaz::State::Redirect.new(@session, model)
      end

      def update
        artobject_id = @session.user_input(:artobject_id)
        mandatory = %i[
          title artgroup_id serie_id serie_position tool_id material_id date
          country_id
        ]
        keys = %i[
          tags_to_s location form_language price size text url
          wordpress_url
        ].concat(mandatory)
        update_hash = {}
        user_input(keys, mandatory).each { |key, value|
          if match = key.to_s.match(/(form_)(.*)/)
            update_hash.store(match[2].intern, value)
          elsif key == :tags_to_s
            if value
              update_hash.store(:tags, value.split(','))
            else
              update_hash.store(:tags, [])
            end
          elsif key == :date
            update_hash.store(
              :date, "#{value.year}-#{value.month}-#{value.day}")
          else
            update_hash.store(key, value)
          end
        }
        unless error?
          if artobject_id
            @session.app.update_artobject(artobject_id, update_hash)
            model = @session.lookandfeel.event_url(:works, :shorts)
            model << "##{artobject_id}"
            DaVaz::State::Redirect.new(@session, model)
          else
            insert_id  = @session.app.insert_artobject(update_hash)
            image_path = @model.artobject.tmp_image_path
            DaVaz::Util::ImageHelper.store_tmp_image(image_path, insert_id)
            AdminAjaxShortGallery.new(@session, [])
          end
        else
          model = @session.lookandfeel.event_url(:works, :shorts)
          model << "##{artobject_id}"
          DaVaz::State::Redirect.new(@session, model)
        end
      end
    end
  end
end
