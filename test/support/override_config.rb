# some helper constant for tests
begin
  require 'pry'
rescue LoadError # ignore errors when loading pry
end
require 'davaz'
require 'util/config'
require 'sbsm/logger'
require 'mail'
require 'support/stub/db_manager'
require 'simplecov_setup'

# 11090 must be in sync with first line in test/config.ru
TEST_SRV_URI = URI.parse(ENV['TEST_SRV_URL'] || 'http://localhost:11090')
TEST_APP_URI = URI.parse(ENV['TEST_APP_URL'] || 'druby://localhost:11091')
TEST_LOG_FILE = 'testing.log'

DaVazUrl = TEST_SRV_URI.to_s
DaVaz.config.server_uri    = TEST_APP_URI.to_s
DaVaz.config.server_name   = TEST_SRV_URI.hostname
DaVaz.config.server_port   = TEST_SRV_URI.port
Mail.defaults { delivery_method :test }
root_dir = Pathname.new(__FILE__).parent.parent.parent.expand_path
TEST_CHRONO_LOGGER = File.join(root_dir, TEST_LOG_FILE)
TEST_RACK_CHRONO_LOGGER = File.join(root_dir, 'test_rack.log')
DaVaz.config.log_pattern = TEST_CHRONO_LOGGER
DaVaz.config.document_root = root_dir.join('doc').to_s
exit 3 unless File.directory?(DaVaz.config.document_root)
DaVaz.config.environment   = 'test'
DaVaz.config.autologin     = false
DaVaz.config.db_manager    = DaVaz::Stub::DbManager.new
TEST_USER = DaVaz.config.test_user ||  'right@user.ch'
TEST_PASSWORD = DaVaz.config.test_password || 'abcd'
puts "TEST_USER #{TEST_USER} #{TEST_PASSWORD}"
