require 'digest/sha2'

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
      action == 'edit' && site =='com.davaz'
    end

    def generate_token
      '1234'
    end
  end

  class YusServer
    def login(email, pass, config)
      raise Yus::YusError unless email == 'right@user.ch'
      User.new
    end

    def logout(*args)
    end
  end
end
