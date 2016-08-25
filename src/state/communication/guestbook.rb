require 'state/communication/global'
require 'view/_partial/ajax'
require 'view/communication/guestbook'
require 'view/communication/guestbook_entry'

module DaVaz::State
  module Communication
    # @api ajax
    class AjaxGuestbookEntry < SBSM::State
      VIEW     = DaVaz::View::Communication::GuestbookEntryForm
      VOLATILE = true
    end

    # @api ajax
    class AjaxSubmitStatus < SBSM::State
      VIEW     = DaVaz::View::Ajax
      VOLATILE = true

      def init
        mandatory = [:name, :messagetxt]
        keys = mandatory + [:surname, :email, :city, :country]
        hash = user_input(keys, mandatory)
        hash[:name] = "#{hash[:name]} #{hash[:surname]}"
        hash.delete(:surname)
        @model = {}
        messages = []
        if error?
          @model[:success] = false
          @errors.each { |key, value|
            messages.push(@session.lookandfeel.lookup(value.message))
          }
          @model[:messages] = messages.join('<br />')
        else
          hash.each { |key, value|
            hash[key] = value
          }
          @session.app.insert_guest(hash)
          @model[:success] = true
        end
      end
    end

    class Guestbook < Global
      VIEW = DaVaz::View::Communication::Guestbook

      def init
        @model = @session.app.load_guests
      end

      # @api ajax
      # @note responds to:
      #   GET /de/communication/ajax_guestbookentry
      def ajax_guestbookentry
        AjaxGuestbookEntry.new(@session, @model)
      end

      # @api ajax
      # @note responds to:
      #   POST /de/communication
      def ajax_submit_entry
        AjaxSubmitStatus.new(@session, @model)
      end
    end

    # @api admin
    class AdminGuestbook < Guestbook
      VIEW = DaVaz::View::Communication::AdminGuestbook
    end
  end
end
