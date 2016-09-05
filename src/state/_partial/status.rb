require 'sbsm/state'
require 'state/predefine'
require 'view/_partial/ajax'

module DaVaz::State
  # @api admin
  # @api ajax
  class AdminAjaxCheckRemovalStatus < SBSM::State
    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      super
      # server does not respond :(
      sleep([0.4, 0.5, 0.6, 0.7, 0.8].sample)
      select_class = @session.user_input(:select_name).to_s.split('_').first
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
end
