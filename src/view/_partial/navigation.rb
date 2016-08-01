require 'htmlgrid/divcomposite'
require 'htmlgrid/div'
require 'htmlgrid/divcomposite'
require 'view/_partial/maillink'
require 'htmlgrid/span'
require 'htmlgrid/ulcomposite'
require 'htmlgrid/spancomposite'
require 'view/_partial/composite'
require 'htmlgrid/dojotoolkit'

module DaVaz::View
  class NavigationComposite < HtmlGrid::SpanComposite
    COMPONENTS   = {}
    CSS_CLASS    = 'navigation'
    NAV_LINK_CSS = 'navigation'
    NAV_METHOD   = :navigation
    SYMBOL_MAP   = {
      :pipe_divider => HtmlGrid::Text
    }

    def init
      build_navigation
      super
    end

    def build_navigation
      @link_idx = 0
      @zone_links = @lookandfeel.send(self::class::NAV_METHOD)
      @zone_links.each_with_index { |ary, idx|
        pos = [idx * 2, 0]
        components.store(pos, :navigation_link)
        components.store([idx * 2 - 1, 0], 'pipe_divider') if idx > 0
      }
    end

    def navigation_link(model)
      zone, event = *(@zone_links.at(@link_idx))
      @link_idx += 1
      unless event
        self.send(zone, model)
      else
        link = HtmlGrid::Link.new(event, model, @session, self)
        link.href = @lookandfeel.event_url(zone, event)
        if(@session.event && @session.event == event)
          link.css_class = self::class::CSS_CLASS + '-active'
        else
          link.css_class = self::class::CSS_CLASS
        end
        link
      end
    end

    def email_link(model)
      link = MailLink.new(:contact_email, model, @session, self)
      link.mailto    = @lookandfeel.lookup(:email_juerg)
      link.css_class = self::class::CSS_CLASS
      link
    end

    def login_form(model)
      link = HtmlGrid::Link.new(:login, model, @session, self)
      link.css_class = self::class::CSS_CLASS
      url = @lookandfeel.event_url(:admin, :login_form)
      link.href = 'javascript:void(0)'
      link.set_attribute('onclick', "toggleLoginForm(this, '#{url}')")
      link
    end

    def logout(model)
      link = HtmlGrid::Link.new(:logout, model, @session, self)
      link.set_attribute('onclick', 'logout(this);')
      link.href = @lookandfeel.event_url(:admin, :logout)
      link.css_class = 'foot-navigation'
      link
    end
  end

  module TopNavigationModule
    class Composite < NavigationComposite
      CSS_CLASS  = 'top-navigation'
      NAV_METHOD = :top_navigation
    end
  end

  class InitTopNavigation < HtmlGrid::DivComposite
    CSS_CLASS  = 'top-navigation'
    COMPONENTS = {
      [0, 0] => TopNavigationModule::Composite,
    }
  end

  class TopNavigation < NavigationComposite
    CSS_CLASS  = 'top-navigation'
    NAV_METHOD = :top_navigation
  end

  class FootNavigation < NavigationComposite
    CSS_CLASS  = 'foot-navigation'
    NAV_METHOD = :foot_navigation
  end

  class LeftNavigation < HtmlGrid::UlComposite
    CSS_ID     = 'left_navigation'
    COMPONENTS = { }

    def init
      @evt = @session.event
      links = [
        :drawings, :paintings, :multiples, :movies, :photos,
        :design, :schnitzenthesen, :empty_link
      ]
      @small_links = [
        :gallery, :articles, :lectures, :exhibitions
      ]
      links.concat(@small_links).each_with_index { |key, idx|
        components.store(idx, key)
        css_id    = key.to_s
        css_class = 'left-navigation'
        zone = @session.zone
        if @evt == key
          css_id << '_active'
        end

        if @small_links.include?(key)
          css_class << '-small'
        end
        css_id_map.store(idx, css_id)
        css_map.store(idx, css_class)
      }
      super
    end

    def drawings(model)
      navigation_link(model, :works, :drawings)
    end

    def paintings(model)
      navigation_link(model, :works, :paintings)
    end

    def multiples(model)
      navigation_link(model, :works, :multiples)
    end

    def movies(model)
      navigation_link(model, :works, :movies)
    end

    def photos(model)
      navigation_link(model, :works, :photos)
    end

    def design(model)
      navigation_link(model, :works, :design)
    end

    def schnitzenthesen(model)
      navigation_link(model, :works, :schnitzenthesen)
    end

    def empty_link(model)
      ''
    end

    def gallery(model)
      navigation_link(model, :gallery, :gallery)
    end

    def articles(model)
      navigation_link(model, :public, :articles)
    end

    def lectures(model)
      navigation_link(model, :public, :lectures)
    end

    def exhibitions(model)
      navigation_link(model, :public, :exhibitions)
    end

    def navigation_link(model, zone, key)
      link = HtmlGrid::Link.new(key, model, @session, self)
      link.href = @lookandfeel.event_url(zone, key)
      css = if @small_links.include?(key)
        'small-lnavlink'
      else
        'lnavlink'
      end
      css << '-active' if @evt == key
      link.css_id    = key.to_s
      link.css_class = css
      link.value = @lookandfeel.lookup(key)
      link
    end
  end

  class GalleryNavigation < HtmlGrid::SpanComposite
    CSS_CLASS = 'gallery-navigation'
    COMPONENTS = {
    }

    def init
      @model = @model.artgroups
      build_navigation()
      super
    end

    def gallery(model)
      link = HtmlGrid::Link.new(:gallery, model, @session, self)
      link.href = @lookandfeel.event_url(:gallery, :search, [
        [:search_query, @session.user_input(:search_query)]
      ])
      link.css_class = self::class::CSS_CLASS
      link
    end

    def build_navigation
      @link_idx = 0
      @model.each_with_index { |event, idx|
        pos = [idx * 2, 0]
        components.store(pos, :navigation_link)
        if idx > 0 && idx != 7
          components.store([idx * 2 - 1, 0], 'pipe_divider')
        else
          components.store([idx * 2 - 1, 0], 'br')
        end
      }
    end

    def navigation_link(model)
      artgroup = @model.at(@link_idx - 2).name.downcase
      artgroup_id = @model.at(@link_idx - 2).artgroup_id
      @link_idx += 1
      link = HtmlGrid::Link.new(artgroup.intern, model, @session, self)
      link.href = @lookandfeel.event_url(:gallery, :search, [
        [:artgroup_id, artgroup_id]
      ])
      link.css_class = self::class::CSS_CLASS
      link
    end
  end
end
