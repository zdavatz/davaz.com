require 'sbsm/state'
require 'state/predefine'
require 'view/_partial/live_edit'

module DaVaz::State
  # @api admin
  class AdminAddNewElement < SBSM::State
    VIEW     = DaVaz::View::AdminLiveEditWidget
    VOLATILE = true
  end

  # @api admin
  # @api ajax
  class AdminAjaxAddNewElement < SBSM::State
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

  # @api admin
  # @api ajax
  class AdminAjaxRemoveElement < SBSM::State
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
  # @api ajax
  class AdminAjaxDeleteElement < SBSM::State
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
end
