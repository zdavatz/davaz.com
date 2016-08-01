require 'sbsm/state'
require 'state/predefine'
require 'view/_partial/ajax'
require 'view/admin/ajax'
require 'util/image_helper'

module DaVaz::State
  module Admin
    class AjaxCheckRemovalStatus < SBSM::State
      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        select_class = @session.user_input(:select_name).split('_').first
        count_method = "count_#{select_class}_artobjects".to_sym
        @model = {'removalStatus' => 'unknown'}
        return unless @session.app.respond_to?(count_method)

        artobject_id = @session.user_input(:artobject_id)
        selected_id  = @session.user_input(:selected_id)
        count = @session.app.send(count_method, selected_id).to_i
        if check_removal(count, select_class, selected_id, artobject_id)
          @model['removalStatus'] = 'goodForRemoval'
        else
          @model['removalStatus'] = 'notGoodForRemoval'
        end
        @model['removeLinkId'] = "#{select_class}_remove_link"
      end

      # Returns removable or not
      #
      # @param count [Integer] artobjects count
      # @param select_class [String]
      # @param selected_id [String]
      # @param artobject_id [String]
      # @return [Boolean] removablility of this artobject
      def check_removal(count, select_class, selected_id, artobject_id)
        return false if count >  1
        return true  if count != 1
        @session.app.send(
          "load_#{select_class}_artobject_id".to_sym, selected_id) == \
        artobject_id
      end
    end

    class AjaxDeleteElement < SBSM::State
      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        @model = Hash.new
        if @session.app \
            .delete_artobject(@session.user_input(:artobject_id)) > 0
          @model['deleted'] = true
        end
      end
    end

    class AjaxDeleteGuest < SBSM::State
      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        @model = Hash.new
        if @session.app \
            .delete_guest(@session.user_input(:guest_id)) > 0
          @model['deleted'] = true
        end
      end
    end

    class AjaxDeleteImage < SBSM::State
      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        @model = {'status' => 'not deleted'}
        if Util::ImageHelper.delete_image(@session.user_input(:artobject_id))
          @model['status'] = 'deleted'
        end
      end
    end

    module ValueUpdatable
      def init(target)
        update_value = @session.user_input(:update_value)
        if update_value.empty?
          update_value = @session.lookandfeel.lookup(:click2edit)
        end
        field_key = @session.user_input(:field_key).to_sym
        update_hash = {field_key => update_value}
        target_id = @session.user_input("#{target}_id")
        @session.app.send("update_#{target}".to_sym, target_id, update_hash)

        data = @session.app.send("load_#{target}".to_sym, target_id)
        @model = {
          'updated_value' => data.send(field_key),
        }
      end
    end

    class AjaxSaveLiveEdit < SBSM::State
      include ValueUpdatable

      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        super :artobject
      end
    end

    class AjaxSaveGbLiveEdit < SBSM::State
      include ValueUpdatable

      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        super :guest
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
    class AjaxUploadImage < SBSM::State
      include Magick

      VIEW     = DaVaz::View::Admin::AjaxUploadImage
      VOLATILE = true

      def init
        string_io = @session.user_input(:image_file)
        if string_io
          artobject_id = @model.artobject.artobject_id
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
            @model.artobject.tmp_image_path = path
          end
        end
      end
    end

  end
end
