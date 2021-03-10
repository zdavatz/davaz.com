#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'util/pw_server'

class PwServer
  def PwServer.show_test_password_yaml
    return if defined?(@@mySalt) # in this case test/pw_server.passwords exists
    entry1 = PwServer.generate_pw_entry("good_user1", "good_password1")
    entry2 = PwServer.generate_pw_entry("good_user2", "good_password2")
    entries = [entry1, entry2]
    puts YAML.dump(entries)
  end
end

class TestPwServer < Minitest::Test

  def setup
    PwServer.show_test_password_yaml
    @pw_server = PwServer.new
  end

  def test_generate_pw_entry
    PwServer.generate_pw_entry("good_user", "good_password")
  end

  def test_login_okay
    result = @pw_server.login("good_user1", "good_password1") 
    assert(result==3276163622155287083, "login must succed for good_user1 but was #{result}")
    result = @pw_server.login("good_user2", "good_password2") 
    assert(result==729312564101876492, "login must succed for good_user2 but was #{result}")
  end
  def test_login_fail
    result = @pw_server.login("good_user1", "bad_password1") 
    assert(result==false, "login must fail with bad password for good_user1")
    result = @pw_server.login("good_user2", "bad_password2") 
    assert(result==false, "login must fail with bad password for good_user2")
  end
  def test_login_fail_for_unknown_user
    result = @pw_server.login("unknown_user", "good_password1") 
    assert(result==false, "login must fail with for unknown_user")
  end

  def test_token_okay
    result = @pw_server.login_token("good_user1", "3276163622155287083") 
    assert(result==true, "token must succed for good_user1 but was #{result}")
    result = @pw_server.login_token("good_user1", 3276163622155287083) 
    assert(result==true, "token must succed for good_user1 but was #{result}")
  end
  def test_token_fail
    result = @pw_server.login_token("good_user1", "22222222") 
    assert(result==false, "token must fail for good_user1 with wrong token")
    result = @pw_server.login_token("unknown_user", "3276163622155287083") 
    assert(result==false, "token must fail for unknown_user")
  end

  def test_logout
    result = @pw_server.logout(3276163622155287083) 
    assert(result==true, "logout must succed for good token")
    result = @pw_server.logout(333) 
    assert(result==true, "logout must succed for bad token??")
  end

end
