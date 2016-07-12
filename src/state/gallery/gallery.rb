require 'state/global_predefine'
require 'state/art_object'
require 'view/gallery/gallery'
require 'view/art_object'
require 'view/rack_art_object'
require 'view/ajax_response'

module DAVAZ
  module State
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

      class AjaxAdminDeskArtobject < SBSM::State
        include AjaxDeskArtobjectLoadable
        include AdminArtObjectMethods

        VIEW     = View::AdminRackArtObjectComposite
        VOLATILE = true

        def init
          super
          @model.fragment = "Desk_#{serie_id}_#{artobject_id}"
          build_selections
        end
      end

      class AjaxDeskArtobject < SBSM::State
        include AjaxDeskArtobjectLoadable

        VIEW     = View::RackArtObjectComposite
        VOLATILE = true
      end

      class AjaxDesk < SBSM::State
        VIEW     = View::Gallery::RackResultListComposite
        VOLATILE = true

        def init
          serie_id = @session.user_input(:serie_id)
          @model = @session.app.load_serie(serie_id).artobjects
        end
      end

      class AjaxRack < SBSM::State
        VOLATILE = true
        VIEW     = View::AjaxResponse

        def init
          artobject_ids = []
          images = []
          titles = []
          serie_id = @session.user_input(:serie_id)
          serie = @session.load_serie(serie_id)
          if serie
            serie.artobjects.each { |obj|
              if Util::ImageHelper.has_image?(obj.artobject_id)
                image = Util::ImageHelper.image_url(obj.artobject_id, 'slide')
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
            'imageHeight'  => DAVAZ.config.slideshow_image_height,
            'serieId'      => serie_id,
          }
          @filter = Proc.new { |model|
            model.store('dataUrl', @request_path)
            model
          }
        end
      end

      class Gallery < State::Gallery::Global
        VIEW = View::Gallery::Gallery

        def init
          @model = OpenStruct.new
          @model.oneliner  = @session.app.load_oneliner('index')
          @model.series    = @session.app.load_series
          @model.artgroups = @session.app.load_artgroups
        end
      end

      class AdminGallery < State::Gallery::Gallery
        include AdminArtObjectMethods

        VIEW = View::Gallery::AdminGallery
      end
    end
  end
end
