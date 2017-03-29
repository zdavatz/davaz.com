require 'sbsm/state'
require 'state/global'
require 'state/predefine'
require 'view/_partial/ajax'
require 'view/_partial/art_object'
require 'util/image_helper'

module DaVaz::State
  # @api admin
  # @api ajax
  class AdminAjaxUploadImageForm < SBSM::State
    VIEW     = DaVaz::View::AdminAjaxUploadImageForm
    VOLATILE = true

    def init
      @model = @session.app \
        .load_artobject(@session.user_input(:artobject_id))
    end
  end

  # @api admin
  # @api ajax
  class AdminAjaxDeleteImage < SBSM::State
    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      @model = {'status' => 'not deleted'}
      if DaVaz::Util::ImageHelper.delete_image(@session.user_input(:artobject_id))
        @model['status'] = 'deleted'
      end
    end
  end

  # @api admin
  # @api ajax
  class AdminAjaxUploadImage < SBSM::State
    include Magick

    VIEW     = DaVaz::View::AdminAjaxUploadImage
    VOLATILE = true

    def init
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
end
