require 'state/predefine'
require 'view/_partial/ajax'
require 'view/_partial/art_object'
require 'util/image_helper'

module DaVaz::State
  # @api admin
  # @api ajax
  # @note responds to:
  #   /de/gallery/ajax_add_form/artobject_id/XXX/name/{serie|tool|material}
  class AdminAjaxAddForm < SBSM::State
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


  # @api admin
  module AdminValueEditable
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

  # @api admin
  # @api ajax
  class AdminAjaxSaveLiveEdit < SBSM::State
    include AdminValueEditable

    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      super :artobject
    end
  end

  # @api admin
  # @api ajax
  # @note responds to:
  #   POST /de/admin/ajax_save_gb_live_edit
  class AdminAjaxSaveGbLiveEdit < SBSM::State
    include AdminValueEditable

    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      super :guest
    end
  end
end
