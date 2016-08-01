require 'sbsm/request'
require 'davaz'
require 'util/config'

DRb.start_service('druby://localhost:0')

begin
	SBSM::Request.new(DaVaz.config.server_uri).process
rescue Exception => e
	$stderr << 'DaVaz-Client-Error: ' << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
