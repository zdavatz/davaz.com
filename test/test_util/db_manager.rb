#!/usr/bin/env ruby
# TestDbManager -- davaz.com -- 26.08.2005 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'util/davazconfig'
require 'test/unit'
require 'util/db_manager'
require 'mysql'

module DAVAZ
	module Util
		class DbManager
			DB_CONNECTION_DATA = File.expand_path('../data/etc/db_connection_data.yml', File.dirname(__FILE__))
			def connect
				StubConnection.new	
			end
		end
	end
end
class StubResult
	def initialize(fields)
		@fields = fields
	end
	def each_hash(&block)
		@fields.each(&block)
	end
end
class StubConnection
	attr_accessor :query_str, :result, :reconnect
	def artgroups_result
		hsh = {
			{
				'artgroup_id'		=>	'MOV',
			} => '',
			{
				'artgroup_id'		=>	'DRA',
			} => '',
		} 
		StubResult.new(hsh)
	end
	def slideshow_result
		hsh = {
			{
				'display_id'		=>	'0',
				'artobject_id'	=>	'23',
				'title'					=>	'test title',
				'position'			=>	'A',
			} => '',
			{
				'display_id'		=>	'24',
				'artobject_id'	=>	'25',
				'title'					=>	'test title',
				'position'			=>	'B',
			} => '',
		} 
		StubResult.new(hsh)
	end
	def query(query)
		unless(@result.nil?)
			self.send(@result)
		else
			@query_str = query
			StubResult.new([])	
		end
	end
end
class StubModel
	attr_accessor :mysql_id, :foo, :bar
end

class DbManager < Test::Unit::TestCase
	def setup
		@manager = DAVAZ::Util::DbManager.new
	end
	def test_connection
		assert_equal(StubConnection, @manager.connection.class)
	end
	def test_load_artgroups
		@manager.connection.result = :artgroups_result
		result = @manager.load_artgroups
		assert_equal(['DRA', 'MOV'], result.collect{ |x| x.artgroup_id }.sort)
	end
end
