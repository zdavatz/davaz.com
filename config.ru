lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'src').untaint)
$LOAD_PATH << lib_dir
require 'util/config' # load config from etc/config.yml
require 'davaz'
require 'util/app'
require 'rack'
require 'rack/static'
require 'rack/show_exceptions'
require 'rack'
require 'sbsm/logger'
require 'webrick'

SBSM.logger= ChronoLogger.new(DaVaz.config.log_pattern)
use Rack::CommonLogger, SBSM.logger
use(Rack::Static, urls: ["/doc/"])
use Rack::ContentLength
use Rack::Lint
use Rack::RewindableInput::Middleware
SBSM.info "Starting Rack::Server DaVaz::DaVaz::Util.new with log_pattern #{DaVaz.config.log_pattern}"
app = Rack::ShowExceptions.new(DaVaz::Util::RackInterface.new())
run app
