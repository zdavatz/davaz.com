require 'pathname'

root_dir = Pathname.new(__FILE__).parent.parent.expand_path

config_yml = "#{root_dir.join('etc').to_s}/config.yml"
FileUtils.cp(config_yml +'.ci', config_yml) unless File.exist?(config_yml)

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
TEST_CLIENT_TIMEOUT = 3 # seconds

dojo = File.join(root_dir, 'doc/resources/dojo/dojo/dojo.js')
if File.exist?(dojo)
  puts "found #{dojo}"
else
  download_url = 'http://download.dojotoolkit.org/release-1.7.10/dojo-release-1.7.10.tar.gz'
  puts "Installing #{File.basename(download_url, '.tar.gz')}"
  cache_file = File.join(Dir.pwd, 'dojo', File.basename(download_url))
  FileUtils.makedirs(File.dirname(cache_file), :verbose => true)
  unless File.exist?(cache_file)
    puts "downloading from #{download_url}"
    saved_dir = Dir.pwd
    Dir.chdir(File.dirname(cache_file))
    exit 3 unless system("wget #{download_url}")
    Dir.chdir(saved_dir)
  end
  exit 4 unless system( "tar --directory doc/resources -xf #{cache_file}")
  FileUtils.mv(Dir.glob('doc/resources/dojo-release*').first, 'doc/resources/dojo', :verbose => true)
end

# test data
module DaVaz; module Stub; end; end

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }

module DaVaz::TestCase
  include WaitUntil
end

Watir.driver = :webdriver
Watir.load_driver
Watir.default_timeout = TEST_CLIENT_TIMEOUT
