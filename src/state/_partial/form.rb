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
  module AdminValueUpdatable
    def init(target)
      update_value = @session.user_input(:update_value)
      if update_value.empty?
        update_value = @session.lookandfeel.lookup(:click2edit)
      end
      field_key = @session.user_input(:field_key).to_sym

      # fix date object for mysql2
      if field_key == :date_ch
        field_key, origin_key = [:date, :date_ch]
        update_value = begin
                         Date.parse(update_value)
                       rescue
                         Date.today
                       end.strftime('%Y-%m-%d')
      else
        origin_key = field_key
      end
      update_hash = {field_key => update_value}

      target_id = @session.user_input("#{target}_id")
      @session.app.send("update_#{target}".to_sym, target_id, update_hash)
      data = @session.app.send("load_#{target}".to_sym, target_id)
      @model = {
        'updated_value' => data.send(origin_key),
      }
    end
  end

  # @api admin
  module AdminTooltipValueUpdatable
    def init(target)
      update_value = @session.user_input(:update_value)
      if update_value.empty?
        update_value = @session.lookandfeel.lookup(:click2edit)
      end
      field_key = @session.user_input(:field_key).to_sym
      update_hash = {field_key => update_value}

      target_id = @session.user_input("#{target}_id")
      @session.app.send("update_#{target}".to_sym, target_id, update_hash)
      data = @session.app.send("load_#{target}".to_sym, target_id.to_i)
      value = ''
      if field_key.to_s =~ /\Aartobject_id\z/
        value = data.artobjects.first.send(:artobject_id)
      else
        method = field_key.to_s =~ /\Alinked_/
        value = data.send(field_key.to_s.gsub(/\Alinked_/, '').to_sym)
      end
      # data is link
      from_obj = @session.app.load_artobject(data.artobject_id)
      if from_obj
        from_url = @session.lookandfeel.event_url(:gallery, :art_object, [
          [:artgroup_id,  from_obj.artgroup_id],
          [:artobject_id, from_obj.artobject_id]
        ])
      else
        from_url = 'unknown'
      end
      to_obj = data.artobjects.first
      if to_obj
        to_url = @session.lookandfeel.event_url(:gallery, :art_object, [
          [:artgroup_id,  to_obj.artgroup_id],
          [:artobject_id, to_obj.artobject_id]
        ])
      else
        to_url = 'unknown'
      end

      if to_obj
        url = DaVaz::Util::ImageHelper.image_url(to_obj.artobject_id)
      else 
        url = ''
      end
      @model = {
        'updated_value' => value,
        'link_id'       => data.link_id,
        'from_url'      => from_url,
        'to_url'        => to_url,
        'tooltip_src'   => url
      }
    end
  end

  # @api admin
  # @api ajax
  #   POST /de/admin/ajax_save_live_edit
  class AdminAjaxSaveLiveEdit < SBSM::State
    include AdminValueUpdatable

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
    include AdminValueUpdatable

    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      super :guest
    end
  end

  # @api admin
  # @api ajax
  # @note responds to:
  #   POST /de/admin/ajax_save_ol_live_edit
  class AdminAjaxSaveOlLiveEdit < SBSM::State
    include AdminValueUpdatable

    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      super :oneliner
    end
  end

  # @api admin
  # @api ajax
  # @note responds to:
  #   POST /de/admin/ajax_save_tp_live_edit
  class AdminAjaxSaveTpLiveEdit < SBSM::State
    include AdminTooltipValueUpdatable

    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      super :link
    end
  end
end
