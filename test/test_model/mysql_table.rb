#!/usr/bin/env ruby
# TestMySQLTable -- davaz.com -- 24.08.2005 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/mysql_table'
require 'model/mysql_connection'

module DAVAZ
	class MySQLTable < MySQLConnection
		TABLE = 'test'
	end
end

class TestMySQLTable < Test::Unit::TestCase
	def setup
		@table = DAVAZ::MySQLTable.new
	end
	def test_select_all
		result = @table.select_all
		assert_equal(Mysql::Result, result.class) 
		assert_equal(3, result.num_fields)
		assert_equal(2, result.num_rows)
	end
	def test_select_by_id
		result = @table.select_by_id(2)
		assert_equal(Mysql::Result, result.class) 
		assert_equal(1, result.num_rows)
		expected = {
			'id'						=>	'2',
			'name'					=>	'second_id',
			'abbreviation'	=>	'sec',
		}
		assert_equal(expected, result.fetch_hash)
	end
end
