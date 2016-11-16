#\ -w -p 11090
# 11090 must be in sync with TEST_SRV_URI from tst_util.rb
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '../src').untaint)
$LOAD_PATH << lib_dir
$LOAD_PATH << File.dirname(lib_dir)
require 'util/config'
require 'test/support/override_config.rb' # to override the DRB-port
require 'util/app'
use Rack::CommonLogger, ChronoLogger.new(TEST_CHRONO_LOGGER)
use Rack::Reloader, 0
use Rack::ContentLength
use(Rack::Static, urls: ["/doc/"])
app = Rack::ShowExceptions.new(Rack::Lint.new(DaVaz::Util::App.new()))
run app
