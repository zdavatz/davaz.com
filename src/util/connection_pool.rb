#!/usr/bin/env ruby
# ConnectionPool -- ODBA -- 08.03.2005 -- hwyss@ywesee.com

require 'dbi'
require 'thread'

module ODBA
	class ConnectionPool
		POOL_SIZE = 5
		SETUP_RETRIES = 3
		attr_reader :connections
		def initialize(*dbi_args)
			@dbi_args = dbi_args
			@connections = []
			@mutex = Mutex.new
			connect
		end
		def next_connection
			conn = nil
			@mutex.synchronize {
				conn = @connections.at(@pos)
				@pos = (@pos + 1) % POOL_SIZE
			}
			conn
		end
		def method_missing(method, *args, &block)
			tries = SETUP_RETRIES
			begin
				next_connection.send(method, *args, &block)
			rescue NoMethodError, DBI::DatabaseError
				if(tries > 0)
					sleep(SETUP_RETRIES - tries)
					tries -= 1
					reconnect
					retry
				else
					raise
				end
			end
		end
		def pool_size
			@connections.size
		end
		def connect 
			@mutex.synchronize { _connect }
		end
		def _connect
			@pos = 0
			POOL_SIZE.times { 
				@connections.push(DBI.connect(*@dbi_args))
			}
		end
		def disconnect 
			@mutex.synchronize { _disconnect }
		end
		def _disconnect
			while(conn = @connections.shift)
				begin 
					conn.disconnect
				rescue DBI::InterfaceError, Exception
					## we're not interested.
				end
			end
		end
		def reconnect
			@mutex.synchronize {
				_disconnect
				_connect
			}
		end
	end
end
