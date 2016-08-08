require 'pathname'

root_dir = Pathname.new(__FILE__).parent.parent.expand_path

src = root_dir.join('src')
$: << src unless $:.include?(src)

test = root_dir.join('test')
$: << test unless $:.include?(test)

require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rclconf'
require 'davaz'
require 'util/config'

module DaVaz
  module Stub; end
end

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }

DaVaz.config.document_root = root_dir.join('doc')
DaVaz.config.autologin     = false

DEBUG = (ENV['DEBUG'] == 'true' || false)
TEST_SRV_URI = URI.parse(ENV['TEST_SRV_HOST'] || 'http://127.0.0.1:10080')
TEST_APP_URI = URI.parse(ENV['TEST_APP_HOST'] || 'druby://127.0.0.1:10081')
