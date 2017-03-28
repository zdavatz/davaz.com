require 'state/global'
require 'view/_partial/tooltip'

module DaVaz::State
  class Tooltip < Global
    VIEW     = DaVaz::View::Tooltip
    VOLATILE = true

    def init
      artobject_id = @session.user_input(:artobject_id)
      model = @session.app.load_artobject(artobject_id)
      if model
        @model = model
      else
        title  = @session.user_input(:title)
        @model = @session.app.load_artobject(title, 'title')
      end
    end
  end

  # @api admin
  # @api ajax
  class AdminAjaxDeleteTooltip < SBSM::State
    VIEW     = DaVaz::View::Ajax
    VOLATILE = true

    def init
      @model = Hash.new
      if @session.app.delete_link(@session.user_input(:link_id)) > 0
        @model['deleted'] = true
      end
    end
  end
end
