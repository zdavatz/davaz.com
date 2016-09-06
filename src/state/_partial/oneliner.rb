require 'state/predefine'

module DaVaz::State
  # @api admin
  # @api ajax
  class AdminAjaxDeleteOneliner < SBSM::State
    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      @model = Hash.new
      if @session.app \
          .delete_oneliner(@session.user_input(:oneliner_id)) > 0
        @model['deleted'] = true
      end
    end
  end
end
