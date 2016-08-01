require 'date'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/button'
require 'view/_partial/list'
require 'view/template'
require 'view/admin/live_edit'

module DaVaz::View
  module Communication
    class Guest < Composite
      CSS_CLASS     = 'guestbook-entry'
      LABELS        = true
      DEFAULT_CLASS = HtmlGrid::Value
      OFFSET_STEP   = [0, 4]
      COMPONENTS    = {
        [0, 0] => :name,
        [0, 1] => :date_gb,
        [0, 2] => :city,
        [0, 3] => :country,
        [0, 4] => :text,
      }
      CSS_MAP = {
        [0, 0, 1, 5] => 'label',
        [1, 0, 1, 5] => 'guestbook-entry-text',
      }
    end

    class GuestList < HtmlGrid::DivList
      COMPONENTS = {
        [0, 0] => Guest,
      }
      CSS_MAP = {
        0 => 'guestbook',
      }
    end

    class GuestbookTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(:davaz_guestbook)
        @value = span
      end
    end

    class GuestbookInfo < HtmlGrid::Div
      CSS_CLASS = 'table-info'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-info'
        span.value     = @lookandfeel.lookup(:guestbook_info)
        @value = span
      end
    end

    class GuestbookButton < HtmlGrid::Div
      CSS_CLASS = 'guestbook-button'

      def init
        super
        button = HtmlGrid::Button.new(:new_entry, model, @session, self)
        button.value     = @lookandfeel.lookup(:new_entry)
        button.css_class = 'new-entry'
        link = HtmlGrid::Link.new(:new_guestbook_entry, model, @session, self)
        link.href  = @lookandfeel.event_url(:communication, :guestbookentry)
        link.value = button
        @value = link
      end
    end

    class GuestbookComposite < HtmlGrid::DivComposite
      CSS_CLASS = 'content'
      COMPONENTS = {
        [0, 0] => GuestbookTitle,
        [1, 0] => GuestbookInfo,
        [2, 0] => :guestbook_widget,
        [3, 0] => GuestList,
      }
      def guestbook_widget(model)
        url = @lookandfeel.event_url(:communication, :ajax_guestbookentry)
        args = [
          [ 'form_url' , url ],
        ]
        dojo_tag("ywesee.widget.GuestbookWidget", args)
      end
    end

    class Guestbook < CommunicationTemplate
      CONTENT = GuestbookComposite
    end

    class AdminGuestList < HtmlGrid::DivList
      COMPONENTS = {
        [0, 0] => Admin::GuestbookLiveEditWidget
      }
      CSS_MAP = {
        0 => 'guestbook'
      }
    end

    # @api admin
    class AdminGuestbookComposite <  HtmlGrid::DivComposite
      CSS_CLASS = 'content'
      COMPONENTS = {
        [0, 0] => GuestbookTitle,
        [1, 0] => GuestbookInfo,
        [2, 0] => :guestbook_widget,
        [3, 0] => AdminGuestList,
      }
      def guestbook_widget(model)
        url = @lookandfeel.event_url(:communication, :ajax_guestbookentry)
        args = [
          [ 'form_url' , url ],
        ]
        dojo_tag("ywesee.widget.GuestbookWidget", args)
      end
    end

    # @api admin
    class AdminGuestbook < AdminCommunicationTemplate
      CONTENT = AdminGuestbookComposite
    end
  end
end
