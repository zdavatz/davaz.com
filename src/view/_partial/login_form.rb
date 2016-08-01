require 'view/template'
require 'view/_partial/form'
require 'htmlgrid/divcomposite'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/pass'
require 'htmlgrid/errormessage'

module DaVaz
  module View
    class LoginForm < View::Form
      include HtmlGrid::ErrorMessage
      COMPONENTS = {
        [0, 0]    => :login_email,
        [0, 1]    => :login_password,
        [0, 2]    => :remember_me,
        [1, 3, 1] => :submit,
        [1, 3, 2] => :cancel,
      }
      CSS_MAP = {
        [0, 0, 3, 3] => 'list',
      }
      CSS_CLASS  = 'component'
      EVENT      = :login
      LABELS     = true
      FORM_NAME  = 'loginform'
      SYMBOL_MAP = {
        :login_password => HtmlGrid::Pass,
      }

      def init
        super
        error_message
        self.onsubmit = 'return false;'
      end

      def cancel(model)
        button = HtmlGrid::Button.new(:cancel, model, @session, self)
        button.css_id = 'login_form_cancel_button'
        button
      end

      def remember_me(model)
        box = HtmlGrid::InputCheckbox.new(
          :remember_me, model, @session, self)
        box.set_attribute 'checked', @session.cookie_set_or_get(:remember)
        box
      end

      def hidden_fields(context)
        super << context.hidden('fragment', "#{@model.fragment}")
      end
    end
  end
end
