require 'state/predefine'
require 'view/_partial/art_object'

module DaVaz::State
  class ArtObject < Global
    VIEW = DaVaz::View::ArtObject

    def init
      artobject_id = @session.user_input(:artobject_id)
      artgroup_id  = @session.user_input(:artgroup_id)
      serie_id     = @session.user_input(:serie_id)
      query        = @session.user_input(:search_query).to_s
      @model = OpenStruct.new
      if !query.empty?
        @model.artobjects = \
          @session.app.search_artobjects(query, artgroup_id)
      elsif serie_id
        @model.artobjects = @session.load_serie(serie_id).artobjects
      elsif artgroup_id
        @model.artobjects = @session.load_artgroup_artobjects(artgroup_id)
      else
        @model.artobjects = []
      end
      object = @model.artobjects.find { |artobject|
        artobject.artobject_id == artobject_id
      }
      if object.nil? && (object = @session.load_artobject(artobject_id))
        @model.artobjects.push(object)
      end
      @model.artobject = object
    end
  end
end
