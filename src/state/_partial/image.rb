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
      if Util::ImageHelper.delete_image(@session.user_input(:artobject_id))
        @model['status'] = 'deleted'
      end
    end
  end

  # @todo
  #class AjaxUploadImage < SBSM::State
  #  include Magick

  #  VIEW     = DaVaz::View::AjaxText
  #  VOLATILE = true

  #  def init
  #    artobject_id = @session.user_input(:artobject_id)
  #    @model = 'not uploaded'
  #    string_io = @session.user_input(:image_file)
  #    if string_io && artobject_id
  #      DaVaz::Util::ImageHelper.store_upload_image(string_io, artobject_id)
  #      @model = DaVaz::Util::ImageHelper.image_url(artobject_id, nil, true)
  #      # no 'else' => new artobject images pass src/state/_partial/art_object
  #      # this is actually highly confusing: why does that happen?
  #    end
  #  end
  #end

  # @api admin
  # @api ajax
  class AdminAjaxUploadImage < SBSM::State
    include Magick

    VIEW     = DaVaz::View::AdminAjaxUploadImage
    VOLATILE = true

    def init
      string_io = @session.user_input(:image_file)
      obj = @model.artobject ? @model.artobject : @model
      if string_io
        artobject_id = obj.artobject_id
        if artobject_id
          DaVaz::Util::ImageHelper.store_upload_image(
            string_io, artobject_id)
          model = OpenStruct.new
          model.artobject = @session.app.load_artobject(artobject_id)
        else
          image = Image.from_blob(string_io.read).first
          path = File.join(
            DaVaz::Util::ImageHelper.tmp_image_dir,
            Time.now.to_i.to_s + "." + image.format.downcase
          )
          image.write(path)
          obj.tmp_image_path = path
        end
      end
    end
  end
end
