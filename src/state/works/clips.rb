require 'rmagick'
require 'sbsm/state'
require 'state/works/global'
require 'state/_partial/art_object'
require 'state/_partial/redirect'
require 'view/works/clips'
require 'view/_partial/art_object'
require 'view/_partial/image'

module DaVaz::State
  module Works

    # @api ajax
    class AjaxClipGallery < SBSM::State
      VIEW     = DaVaz::View::ClipsArtObjectComposite
      VOLATILE = true

      def init
        artobject_id = @session.user_input(:artobject_id)
        @model = OpenStruct.new
        @model.artobjects = @session.app.load_clips
        @model.artobject  = @model.artobjects.find { |obj|
          obj.artobject_id.to_s == artobject_id
        }
      end
    end

    class Clips < Global
      VIEW = DaVaz::View::Works::Clips

      def init
        @model = @session.app.load_clips
      end
    end
  end
end
