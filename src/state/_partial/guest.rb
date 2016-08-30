require 'state/predefine'

module DaVaz::State
  # @api admin
  # @api ajax
  class AdminAjaxDeleteGuest < SBSM::State
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
end
