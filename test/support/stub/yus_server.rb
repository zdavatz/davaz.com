require 'digest/sha2'

module DaVaz
  module Stub

    class User
      attr_reader :valid

      def allowed?(action, site)
        action == 'edit' && site =='com.davaz'
      end

      def valid?
        true
      end
    end

    class YusServer

      def login(email, pass, config)
        # puts "email: #{email}, pass: #{pass}, config: #{config}"
        raise Yus::YusError unless email != 'right@user.ch'
        User.new
      end

      def logout(arg)
      end
    end
  end
end
