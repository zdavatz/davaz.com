require 'pathname'

root_dir = Pathname.new(__FILE__).parent.parent.expand_path

config_yml = "#{root_dir.join('etc').to_s}/config.yml"
FileUtils.cp(config_yml +'.ci', config_yml, :verbose => true) unless File.exist?(config_yml)

src = root_dir.join('src').to_s
$: << src unless $:.include?(src)

test = root_dir.join('test').to_s
$: << test unless $:.include?(test)

require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'watir'
require 'rclconf'
require 'davaz'
require 'util/config'
require 'support/override_config.rb'

# debugging
DEBUG    = (ENV['DEBUG'] == 'true' || false)
DEBUGGER = ENV['DEBUGGER'] \
  if ENV.has_key?('DEBUGGER') && !ENV['DEBUGGER'].empty?
TEST_CLIENT_TIMEOUT = 5 # seconds

# test data
module DaVaz; module Stub; end; end

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }

module DaVaz::TestCase
  include WaitUntil
end

Watir.driver = :webdriver
Watir.load_driver
Watir.default_timeout = TEST_CLIENT_TIMEOUT
