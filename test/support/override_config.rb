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
require 'support/stub/yus_server'

# 11090 must be in sync with first line in test/config.ru
TEST_SRV_URI = URI.parse(ENV['TEST_SRV_URL'] || 'http://localhost:11090')
TEST_APP_URI = URI.parse(ENV['TEST_APP_URL'] || 'druby://localhost:11091')
# 11097 must be in sync with etc/config.yml.ci
TEST_YUS_URI = URI.parse(ENV['TEST_APP_URL'] || 'druby://localhost:11097')


DaVazUrl = TEST_SRV_URI.to_s
DaVaz.config.server_uri    = TEST_APP_URI.to_s
DaVaz.config.server_name   = TEST_SRV_URI.hostname
DaVaz.config.server_port   = TEST_SRV_URI.port
Mail.defaults { delivery_method :test }
root_dir = Pathname.new(__FILE__).parent.parent.parent.expand_path
TEST_CHRONO_LOGGER = File.join(root_dir, 'test.log')
DaVaz.config.log_pattern = TEST_CHRONO_LOGGER
DaVaz.config.document_root = root_dir.join('doc').to_s
exit 3 unless File.directory?(DaVaz.config.document_root)
DaVaz.config.environment   = 'test'
DaVaz.config.autologin     = false
DaVaz.config.db_manager    = DaVaz::Stub::DbManager.new
DaVaz.config.yus_server    = DaVaz::Stub::YusServer.new
