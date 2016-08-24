require 'htmlgrid/errormessage'
require 'htmlgrid/textarea'
require 'htmlgrid/inputtext'
require 'view/_partial/form'
require 'view/template'

module DaVaz::View
  module Communication
    class GuestbookEntryForm < DaVaz::View::Form
      include HtmlGrid::ErrorMessage

      LABELS = true
      EVENT  = :ajax_submit_entry
      CSS_CLASS  = 'guestbookentry-form'
      COMPONENTS = {
        [0, 0]    => :name,
        [2, 0]    => :surname,
        [0, 1]    => :email,
        [0, 2]    => :city,
        [2, 2]    => :country,
        [0, 3]    => :messagetxt,
        [1, 4]    => :submit,
        [1, 4, 1] => :cancel
      }
      COLSPAN_MAP = {
        [1, 3] => 3,
        [1, 4] => 3
      }
      CSS_MAP = {
        [0, 0, 1, 4] => 'labels',
        [2, 0, 1, 3] => 'labels',
        [0, 4]       => 'add-entry'
      }
      SYMBOL_MAP = {
        :name    => HtmlGrid::InputText,
        :surname => HtmlGrid::InputText,
        :city    => HtmlGrid::InputText,
        :country => HtmlGrid::InputText
      }

      def init
        super
        error_message
        self.onsubmit = 'return false;'
      end

      def messagetxt(model)
        input = HtmlGrid::Textarea.new(:messagetxt, model, @session, self)
        input.set_attribute('rows', 10)
        input.set_attribute('wrap', true)
        input.css_id = 'guestbook_message'
        input.label  = true
        input
      end

      def submit(model)
        button = HtmlGrid::Button.new(
          :ajax_submit_entry, model, @session, self)
        button.value = @lookandfeel.lookup(:ajax_submit_entry)
        button.css_class = 'add-entry'
        button.attributes['type'] = 'submit'
        button
      end

      def cancel(model)
        button = HtmlGrid::Button.new(:cancel, model, @session, self)
        button.value = @lookandfeel.lookup(:cancel)
        button.css_class = 'add-entry'
        button.css_id    = 'cancel_add_entry'
        button
      end
    end
  end
end
