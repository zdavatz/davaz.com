require 'sbsm/session'
require 'util/lookandfeel'

# @todo remove this method
def require_r(dir, prefix)
  path = File.expand_path(dir)
  Dir.entries(path).sort.each { |file|
    next if file =~ /^predefine$/
    if /^[a-z_]+\.rb$/.match(file)
      require([prefix, file].join('/'))
    elsif !/^\./.match(file)
      dirpath = File.expand_path(file, path)
      new_prefix = [prefix, file].join('/')
      if File.ftype(dirpath) == 'directory'
        require_r(dirpath, new_prefix)
      end
    end
  }
end

# states
require 'state/predefine'
require_r(File.expand_path('../../state', __FILE__), 'state')

module DaVaz::Util
  class Session < SBSM::Session
    attr_reader :app
    SERVER_NAME      = DaVaz.config.server_port ? DaVaz.config.server_name + ":#{DaVaz.config.server_port}" : DaVaz.config.server_name
    DEFAULT_STATE          = DaVaz::State::Personal::Init
    DEFAULT_ZONE           = :personal
    DEFAULT_LANGUAGE       = 'en'
    PERSISTENT_COOKIE_NAME = 'davaz.com-preferences'
    LOOKANDFEEL            = Lookandfeel

    def initialize(key, app, validator=Validator.new)
      SBSM.debug "session key #{key} #{app.class} #{validator.class} @app #{@app.class} app #{app.class} @session #{@session.object_id} validator #{validator.class}"
      @app = app # unless @app
      super(key, app, validator)
      if DaVaz.config.autologin
        # use only for debugging purposes as default
        @state.extend(DaVaz::State::Admin)
      end
    end

    def flavor
      # davaz.com does not use flavor
      nil
    end

    def active_state
      @active_state = super
      unless @token_login_attempted
        @token_login_attempted = true
        if user = login_token
          # allow autologin via token
          @active_state.extend(DaVaz::State::Admin)
          if @active_state.respond_to?(:autologin)
            @active_state = @active_state.autologin(user)
          end
        end
      end
      state_id = @valid_input[:state_id]
      res = if state_id
        @attended_states[state_id]
      elsif zone != @zone
        @active_state.switch_zone(zone)
      end || @active_state
    end

    def cap_max_states
      # ignore
    end

    def top_navigation
      @active_state.top_navigation
    end

    def foot_navigation
      @active_state.foot_navigation
    end

    def login
      SBSM.debug "login #{user_input(:login_email)} with #{user_input(:login_password)}"
      # @app.login raises Yus::YusError
      @user = @app.login(user_input(:login_email), user_input(:login_password))
      if @user.valid? && user_input(:remember_me)
        set_cookie_input :remember, @user.generate_token
        set_cookie_input :name,     @user.name || user_input(:login_email)
      else
        @cookie_input.delete :remember
      end
      @user
    end

    def login_token
      # @app.login_token raises Yus::YusError
      name  = (persistent_user_input(:name) || get_cookie_input(:name))
      token = (persistent_user_input(:remember) || get_cookie_input(:remember))
      SBSM.debug "login_token name #{name.inspect} token #{token}"
      if name && token && !token.empty? && \
         (!@user.respond_to?(:valid?) || !@user.valid?)
        @user = @app.login_token(name, token)
        if @user.valid?
          SBSM.debug "set_cookie_input remember #{@user.generate_token}"
          set_cookie_input :remember, @user.generate_token
          @user
        else
          nil
        end
      else
        nil
      end
    rescue Yus::YusError => e
      puts "login #{name} with token #{token.inspect}"
      require 'pry'; binding.pry
    end

    def logout
      SBSM.debug "logout #{@user} with persistent_user_input(remember) #{persistent_user_input(:remember).inspect}"
      @app.logout(@user)
      super
    end
  end
end
