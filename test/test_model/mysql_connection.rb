#!/usr/bin/env ruby
# TestMySQLConnection -- davaz.com -- 23.08.2005 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/mysql_connection'

class TestOneLiner < Test::Unit::TestCase
	def setup
		@mysql = DAVAZ::MySQLConnection.new
	end
	def test_select_all
		result = @mysql.select_all('oneliner')
		assert_equal(Mysql::Result, result.class)
	end
	def test_select_by_id
		result = @mysql.select_by_id('oneliner', 2)
		assert_equal(Mysql::Result, result.class)
		result.each_hash { |row|
			puts row.inspect
		}
	end
end
