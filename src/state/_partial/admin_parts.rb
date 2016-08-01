require 'state/predefine'
require 'view/admin/ajax'
require 'view/_partial/ajax'
require 'view/_partial/admin_parts'

module DaVaz::State
  module Admin
    class AddNewElement < SBSM::State
      VIEW     = DaVaz::View::Admin::LiveEditWidget
      VOLATILE = true
    end

    class AjaxUploadImageForm < SBSM::State
      VIEW     = DaVaz::View::Admin::AjaxUploadImageForm
      VOLATILE = true

      def init
        @model = @session.app \
          .load_artobject(@session.user_input(:artobject_id))
      end
    end
  end
end
