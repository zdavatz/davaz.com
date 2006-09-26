#!/usr/bin/env ruby
# -- davaz.com -- 24.05.2006 -- mhuggler@ywesee.com

require 'yaml'
require 'mysql'

module Selenium
	class TearDown
		DB_CONNECTION_DATA = File.expand_path('../../etc/db_connection_data.yml', File.dirname(__FILE__))
		def initialize
			@connection = connect
		end
		def connect
			db_data = YAML.load(File.read(DB_CONNECTION_DATA.untaint))
			@connection = Mysql.new(db_data['host'], db_data['user'], db_data['password'], db_data['db'])
		end
		def tear_down_guestbook
			query = "DELETE FROM guestbook WHERE name='TestName TestSurname'"
			result = @connection.query(query)
			if(@connection.affected_rows > 0)
				puts "#{@connection.affected_rows} guestbook entries deleted!"
			else
				puts "No guestbook entries affected!"
			end
		end
	end
end
