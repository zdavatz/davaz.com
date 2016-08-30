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
end
