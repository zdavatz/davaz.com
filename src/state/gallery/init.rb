require 'sbsm/state'
require 'state/gallery/global'
require 'state/_partial/art_object'
require 'view/_partial/art_object'
require 'view/_partial/rack'
require 'view/_partial/ajax'
require 'view/gallery/gallery'
require 'view/gallery/result'

module DaVaz::State
  module Gallery
    module AjaxDeskArtobjectLoadable
      def init
        @model = OpenStruct.new
        artobject_id = @session.user_input(:artobject_id)
        serie_id     = @session.user_input(:serie_id)
        serie  = @session.load_serie(serie_id)
        @model.artobjects = serie.artobjects
        @model.artobject  = @model.artobjects.find { |obj|
           obj.artobject_id.to_s == artobject_id
         }
      end
    end

    # @api admin
    # @api ajax
    # @note responds to:
    #   /de/gallery/ajax_desk/artgroup_id/XXX/serie_id/XXX/artobject_id/XXX
    class AdminAjaxDeskArtobject < SBSM::State
      include AdminArtObjectMethods
      include AjaxDeskArtobjectLoadable

      VIEW     = DaVaz::View::AdminRackArtObjectComposite
      VOLATILE = true

      def init
        super
        @model.fragment = 'Desk' \
          "_#{@session.user_input(:serie_id)}" \
          "_#{@session.user_input(:artobject_id)}"
        build_selections
      end
    end

    # @api ajax
    # @note responds to:
    #   /de/gallery/ajax_desk/artgroup_id/XXX/serie_id/XXX/artobject_id/XXX
    class AjaxDeskArtobject < SBSM::State
      include AjaxDeskArtobjectLoadable

      VIEW     = DaVaz::View::RackArtObjectComposite
      VOLATILE = true
    end

    # @api ajax
    # @note responds to:
    #   /de/gallery/ajax_desk/artgroup_id/XXX/serie_id/XXX
    class AjaxDesk < SBSM::State
      VIEW     = DaVaz::View::Gallery::RackResultListComposite
      VOLATILE = true

      def init
        serie_id = @session.user_input(:serie_id)
        @model = @session.app.load_serie(serie_id).artobjects
      end
    end

    # @api ajax
    class AjaxRack < SBSM::State
      VOLATILE = true
      VIEW     = DaVaz::View::Ajax

      def init
        artobject_ids = []
        images = []
        titles = []
        serie_id = @session.user_input(:serie_id)
        serie = @session.load_serie(serie_id)
        if serie
          serie.artobjects.each { |obj|
            if DaVaz::Util::ImageHelper.has_image?(obj.artobject_id)
              image = DaVaz::Util::ImageHelper.image_url(
                obj.artobject_id, 'slide')
              images.push(image)
              titles.push(obj.title)
              artobject_ids.push(obj.artobject_id)
            end
          }
        end
        @model = {
          'artObjectIds' => artobject_ids,
          'images'       => images,
          'titles'       => titles,
          'imageHeight'  => DaVaz.config.show_image_height,
          'serieId'      => serie_id,
        }
        @filter = Proc.new { |model|
          model.store('dataUrl', @request_path)
          model
        }
      end
    end

    class Init < Global
      VIEW = DaVaz::View::Gallery::Gallery

      def init
        @model = OpenStruct.new
        @model.oneliner  = @session.app.load_oneliner('index')
        @model.series    = @session.app.load_series
        @model.artgroups = @session.app.load_artgroups
      end
    end

    # @api admin
    class AdminGallery < Init
      include AdminArtObjectMethods

      VIEW = DaVaz::View::Gallery::AdminGallery
    end
  end
end
