require 'htmlgrid/divcomposite'
require 'htmlgrid/link'
require 'htmlgrid/ullist'
require 'view/_partial/list'
require 'view/_partial/textblock'
require 'view/_partial/oneliner'
require 'view/_partial/serie_widget'
require 'view/_partial/ticker'
require 'view/_partial/composite'
require 'view/template'

module DaVaz::View
  module Personal
    class LifeList < HtmlGrid::UlList
      CSS_ID     = 'biography'
      COMPONENTS = {
        [0, 0] => TextBlock,
      }
    end

    class LifeTimePeriods < Composite
      CSS_ID     = 'life_time_periods'
      COMPONENTS = {
        [0, 0] => :early_years,
        [1, 0] => :time_of_change,
        [2, 0] => :private_life,
        [3, 0] => :change_of_times,
      }
      COMPONENT_CSS_MAP = {
        [0, 0, 4] => 'life-times'
      }

      def early_years(model)
        link = HtmlGrid::Link.new(:early_years, model, @session)
        link.href = '#1946'
        link.css_class = 'no-decoration'
        link.value     = @lookandfeel.lookup(:early_years)
        link
      end

      def time_of_change(model)
        link = HtmlGrid::Link.new(:time_of_change, model, @session)
        link.href = '#1965'
        link.css_class = 'no-decoration'
        link.value     = @lookandfeel.lookup(:time_of_change)
        link
      end

      def private_life(model)
        link = HtmlGrid::Link.new(:private_life, model, @session)
        link.href = '#1975'
        link.css_class = 'no-decoration'
        link.value     = @lookandfeel.lookup(:private_life)
        link
      end

      def change_of_times(model)
        link = HtmlGrid::Link.new(:change_of_times, model, @session)
        link.href = '#1989'
        link.css_class = 'no-decoration'
        link.value     = @lookandfeel.lookup(:change_of_times)
        link
      end
    end

    class LifeTranslations < HtmlGrid::DivComposite
      CSS_ID     = 'life_translations'
      COMPONENTS = {
        [0, 0] => :english,
        [1, 0] => 'pipe_divider',
        [2, 0] => :chinese,
        [3, 0] => 'pipe_divider',
        [4, 0] => :hungarian,
        [5, 0] => 'pipe_divider',
        [6, 0] => :russian,
      }

      def english(model)
        link = HtmlGrid::Link.new(:english, model, @session, self)
        link.value = @lookandfeel.lookup(:english)
        link.href  = @lookandfeel.event_url(:personal, :life, :lang => 'English')
        link.css_class = 'no-decoration'
        lang = @session.user_input(:lang)
        if !lang || lang == 'English'
          link.set_attribute('style','color:black')
        end
        link
      end

      def chinese(model)
        link = HtmlGrid::Link.new(:chinese, model, @session, self)
        link.value = @lookandfeel.lookup(:chinese)
        link.href  = @lookandfeel.event_url(
          :personal, :life, :lang => 'Chinese')
        link.css_class = 'no-decoration'
        if @session.user_input(:lang) == 'Chinese'
          link.set_attribute('style','color:black')
        end
        link
      end

      def hungarian(model)
        link = HtmlGrid::Link.new(:hungarian, model, @session, self)
        link.value = @lookandfeel.lookup(:hungarian)
        link.href  = @lookandfeel.event_url(
          :personal, :life, :lang => 'Hungarian')
        link.css_class = 'no-decoration'
        if @session.user_input(:lang) == 'Hungarian'
          link.set_attribute('style','color:black')
        end
        link
      end

      def russian(model)
        link = HtmlGrid::Link.new(:russian, model, @session, self)
        link.value     = @lookandfeel.lookup(:russian)
        link.href      = @lookandfeel.resource(:cv_russian)
        link.css_class = 'no-decoration'
        link
      end
    end

    class LifeComposite < HtmlGrid::DivComposite
      LIFE_LIST = component(LifeList, :biography_items)
      CSS_CLASS = 'inner-content'
      COMPONENTS = {
        [0, 0] => :india_ticker_link,
        [0, 1] => component(SerieWidget, :show_items, 'slide'),
        [0, 2] => component(OneLiner, :oneliner),
        [0, 3] => LifeTimePeriods,
        [1, 3] => LifeTranslations,
      }

      def init
        reorganize_components
        super
      end

      def reorganize_components
        components[[2,3]] = self.class::LIFE_LIST
      end

      def india_ticker_link(model)
        link = HtmlGrid::Link.new(:india_ticker_link, model, @session, self)
        link.value = @lookandfeel.lookup(:india_ticker_link)
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', 'toggleTicker();')
        div = HtmlGrid::Div.new(model, @session, self)
        div.css_id = 'ticker_link'
        div.value  = link
        div
      end
    end

    class Life < PersonalTemplate
      CONTENT = LifeComposite
      TICKER  = 'A passage through India'
    end

    class AdminLifeList < HtmlGrid::DivComposite
      CSS_ID = 'element_container'
      COMPONENTS = {
        [0, 0] => component(AdminTextBlockList, :biography_items),
      }
    end

    class AdminLifeComposite < LifeComposite
      CSS_ID_MAP = {
        3 => 'biography'
      }

      def reorganize_components
        components.update(
          [2,3] => AdminAjaxAddNewElementComposite,
          [3,3] => AdminLifeList
        )
      end
    end

    class AdminLife < Life
      CONTENT = AdminLifeComposite
    end
  end
end
