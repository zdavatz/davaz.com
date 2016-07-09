require 'pathname'

root_dir = Pathname.new(__FILE__).parent.parent.expand_path
$: << root_dir.join('src')

require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rclconf'
require 'util/config'
require 'util/davaz'

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }

DAVAZ.config.document_root = root_dir.join('doc')
DAVAZ.config.autologin = false

DEBUG = (ENV['DEBUG'] == 'true' || false)
TEST_SRV_URI = URI.parse(ENV['TEST_SRV_HOST'] || 'http://127.0.0.1:10080')
TEST_APP_URI = URI.parse(ENV['TEST_APP_HOST'] || 'druby://127.0.0.1:10081')
