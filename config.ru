#\ -w -p 8007
# 8006 is the port used to serve
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
SBSM.info "Starting Rack::Server DaVaz::DaVaz::Util.new with log_pattern #{DaVaz.config.log_pattern}"
app = Rack::ShowExceptions.new(Rack::Lint.new(DaVaz::Util::App.new()))
run app
