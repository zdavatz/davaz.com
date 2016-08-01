require 'sbsm/state'
require 'state/predefine'
require 'state/_partial/login_methods'
require 'state/_partial/login_form'
require 'state/_partial/ajax'
require 'state/_partial/art_object'
require 'state/_partial/tooltip'
require 'state/communication/global'
require 'state/communication/shop'
require 'state/gallery/global'
require 'state/personal/global'
require 'state/personal/init'
require 'state/works/global'

module DaVaz::State
  class Global < SBSM::State
    include LoginMethods

    attr_reader   :model
    attr_accessor :switched_zone

    GLOBAL_MAP = {
      :art_object         => ArtObject,
      :tooltip            => Tooltip,
      :login_form         => LoginForm,
      :shop_art_object    => Communication::ShopArtObject,
      :ajax_rack          => Gallery::AjaxRack,
      :home               => Personal::Init,
      :ajax_movie_gallery => Works::AjaxMovieGallery
    }
    HOME_STATE = Personal::Init
    VIEW = DaVaz::View::Personal::Init

    def ajax_desk
      if @session.user_input(:artobject_id)
        Gallery::AjaxDeskArtobject.new(@session, [])
      else
        Gallery::AjaxDesk.new(@session, [])
      end
    end

    def ajax_images
      if @model.respond_to?(:show_items)
        Ajax.new(@session, @model.show_items)
      elsif @model.respond_to?(:serie_items)
        Ajax.new(@session, @model.serie_items)
      else
        Ajax.new(@session, @model)
      end
    end

    def error_check_and_store(key, value, mandatory=[])
      if value.is_a?(RuntimeError)
        @errors.store(key, value)
      elsif mandatory.include?(key) && mandatory_violation(value)
        error = create_error('e_missing_fields', key, value)
        @errors.store(key, error)
      end
    end

    def foot_navigation
      [
        :login_form,
        %i{communication guestbook},
        %i{communication shop},
        :email_link,
        %i{communication news},
        %i{communication links},
        %i{personal home}
      ]
    end

    def search_result
      artgroup_id = @session.user_input(:artgroup_id)
      query = @session.user_input(:search_query)
      model = OpenStruct.new
      model.result    = @session.app.search_artobjects(query, artgroup_id)
      model.artgroups = @session.app.load_artgroups
      model
    end

    def search
      model = search_result
      Gallery::Result.new(@session, model)
    end

    def switch_zone(zone)
      name  = zone.to_s.split('_').collect { |word| word.capitalize }.join
      klass = DaVaz::State.const_get(name).const_get('Global')
      newstate = klass.new(@session, @model)
      newstate.unset_previous
      newstate.switched_zone = true
      newstate.previous = self
      newstate
    rescue NameError => e
      puts e.class, e.message
      self
    end

    def top_navigation
      [
        %i{personal life},
        %i{personal work},
        %i{personal inspiration},
        %i{personal family}
      ]
    end

    def trigger(event)
      newstate = super
      if @switched_zone
        newstate.unset_previous
        newstate.previous = @previous
      end
      newstate
    end
  end
end
