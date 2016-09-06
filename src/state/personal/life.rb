require 'state/personal/global'
require 'state/_partial/art_object'
require 'view/personal/life'

module DaVaz::State
  module Personal
    class Life < Global
      VIEW = DaVaz::View::Personal::Life
      DIRECT_EVENT = :life

      def init
        @model = OpenStruct.new
        lang = @session.user_input(:lang) || 'English'
        @model.biography_items = @session.app.load_hislife(lang)
        add_show_items(@model, 'hislife_show')
        @model.oneliner = @session.app.load_oneliner_by_location('hislife')
        @model.serie_id = @session.app.load_serie_id("Site His Life %s" % lang)
      end
    end

    # @api admin
    class AdminAddNewBioElement < AdminAddNewElement
      def init
        lang = @session.user_input(:lang) || 'English'
        insert_id = @session.app.insert_artobject(
          :date     => Date.new(2006).to_s,
          :text     => @session.lookandfeel.lookup(:click2edit_textarea),
          :title    => @session.lookandfeel.lookup(:click2edit),
          :serie_id => @model.serie_id
        )
        @model = @session.app.load_artobject(insert_id)
      end
    end

    # @api admin
    class AdminLife < Life
      VIEW = DaVaz::View::Personal::AdminLife

      def ajax_add_new_element
        AdminAddNewBioElement.new(@session, @model)
      end
    end
  end
end
