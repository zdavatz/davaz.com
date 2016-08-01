require 'state/global'
require 'state/communication/global'
require 'view/_partial/ajax'
require 'view/communication/guestbook'
require 'view/communication/guestbook_entry'

module DaVaz::State
  module Communication
    class GuestbookEntry < Global
      VIEW     = DaVaz::View::Communication::GuestbookEntryForm
      VOLATILE = true
    end

    # @api ajax
    class SubmitStatus < SBSM::State
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

      def ajax_guestbookentry
        GuestbookEntry.new(@session, @model)
      end

      def ajax_submit_entry
        SubmitStatus.new(@session, @model)
      end
    end

    # @api admin
    class AdminGuestbook < Guestbook
      VIEW = DaVaz::View::Communication::AdminGuestbook
    end
  end
end
