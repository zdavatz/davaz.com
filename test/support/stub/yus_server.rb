require 'digest/sha2'

module DAVAZ
  module Stub

    class User
      attr_reader :valid

      def allowed?(action, site)
        if action=='edit' && site =='com.davaz'
          true
        else
          false
        end
      end

      def valid?
        true
      end
    end

    class YusServer

      def login(email, pass, config)
        puts "email: #{email}, pass: #{pass}, config: #{config}"
        if email == 'right@user.ch'
          User.new
        else
          raise Yus::YusError
        end
      end

      def logout(arg)
      end
    end
  end
end
