#\ -w -p 11090
# 11090 must be in sync with TEST_SRV_URI from override_config.rb
root_dir = File.expand_path(File.join(__FILE__, '..', '..'))
$LOAD_PATH << File.join(root_dir, 'test')
require 'test_helper'
use Rack::CommonLogger, ChronoLogger.new(TEST_CHRONO_LOGGER)
use Rack::Reloader, 0
use Rack::ContentLength
use(Rack::Static, urls: ["/doc/"])
app = Rack::ShowExceptions.new(Rack::Lint.new(DaVaz::Util::App.new()))
run app
