require 'digest/sha2'
require 'sbsm/logger'
module DaVaz::Stub
  class User
    attr_reader :valid

    def name
      'name'
    end

    def valid?
      true
    end

    def allowed?(action, site)
      SBSM.info("action #{action} site #{site} result #{(action == 'edit' && site =='com.davaz').inspect}")
      action == 'edit' && site =='com.davaz'
    end

    def generate_token
      SBSM.info("return 1234")
      '1234'
    end
  end

  class YusServer
    def login(email, pass, config)
      SBSM.info("email #{email} pass #{pass} config #{config}'}")
      raise Yus::YusError unless email == 'right@user.ch'
      User.new
    end

    def logout(*args)
      SBSM.info("logout #{args}")
      true
    end
  end
end
