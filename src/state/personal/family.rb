require 'state/personal/global'
require 'view/personal/family'

module DaVaz::State
  module Personal
    class Family < Global
      VIEW = DaVaz::View::Personal::Family

      def init
        @model = OpenStruct.new
        @model.family_text = @session.app.load_hisfamily_text
        add_show_items(@model, 'hisfamily_show')
      end
    end

    # @api admin
    class AdminFamily < Family
      VIEW = DaVaz::View::Personal::AdminFamily
    end
  end
end
