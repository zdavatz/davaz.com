#!/usr/bin/env ruby
# index.rbx -- oddb -- hwyss@ywesee.com
# index.rbx -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'sbsm/request'
require 'util/davazconfig'

DRb.start_service('druby://localhost:0')

begin
	SBSM::Request.new(DAVAZ::SERVER_URI).process
rescue Exception => e
	$stderr << "DAVAZ-Client-Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
