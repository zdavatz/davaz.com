#!/usr/bin/env ruby
# TestDbManager -- davaz.com -- 26.08.2005 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/db_manager'
require 'mysql'

module DAVAZ
	module Util
		class DbManager
			DB_CONNECTION_DATA = File.expand_path('../test_db_connection_data.txt', File.dirname(__FILE__))
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
	attr_accessor :query_str
	def query(query)
		if(query.match(/shop/))
			hsh = {
				{
					'id'				=>	1,
					'name'			=>	'PostersName',
					'artgroup'	=>	'Posters',
				} => '',
				{
					'id'				=>	2,
					'name'			=>	'PublicationsName',
					'artgroup'	=>	'Publications',
				} => '',
				{
					'id'				=>	3,
					'name'			=>	'FilmsName',
					'artgroup'	=>	'Films',
				} => '',
				{
					'id'				=>	4,
					'name'			=>	'FilmsName2',
					'artgroup'	=>	'Films',
				} => '',
				{
					'id'				=>	5,
					'name'			=>	'DesignName',
					'artgroup'	=>	'Design',
				} => '',
			} 
			return StubResult.new(hsh)
		end
		@query_str = query
		StubResult.new([])	
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
	def test_load_db_connection_data
		expected = {
			'host'	=>	'test_host',
			'user'	=>	'test_user',
			'password'	=>	'test_password',
			'db'		=>	'test_db',
		}
		assert_equal(expected, @manager.load_db_connection_data)
	end
	def test_select_query_base
		expected = "SELECT * FROM table"
		assert_equal(expected, @manager.select_query_base('table'))
	end
	def test_select_query_base2
		expected = "SELECT * FROM table ORDER BY date ASC"
		assert_equal(expected, @manager.select_query_base('table', 'ASC'))
	end
	def test_select_query_where
		expected = ['SELECT', '*', 'FROM', 'table', 'WHERE', 
			"id='1'", 'AND', "name='foo'" ].sort
		where = {
			'id'		=>	1,
			'name'	=>	'foo',
		}
		result = @manager.select_query_where('table', where).split(" ").sort
		assert_equal(expected, result)
	end
	def test_select_query_id
		expected = "SELECT * FROM table WHERE id='8'"
		assert_equal(expected, @manager.select_query_id('table', 8))
	end
	def test_select_query_slideshow
		expected = "SELECT * FROM table ORDER BY date DESC LIMIT 8"
		assert_equal(expected, @manager.select_query_slideshow('table', 8))
	end
	def test_create_model_array
		fields = {
			{
				'id'	=>	'test_id',
				'foo'	=>	'test_foo',
				'bar'	=>	'test_bar',
			}	=> nil,
			{
				'id'	=>	'test_id2',
				'foo'	=>	'test_foo2',
				'bar'	=>	'test_bar2',
			}	=> nil,
		}
		result = StubResult.new(fields)
		model_array = @manager.create_model_array(StubModel, result)
		assert_equal(Array, model_array.class)
		assert_equal(2, model_array.size)
		model_array.each { |model|
			assert_equal(StubModel, model.class)
			if(model.mysql_id == 'test_id')
				assert_equal('test_foo', model.foo)
				assert_equal('test_bar', model.bar)
			end
		}
	end
	def test_load_shop_items
		result = @manager.load_shop_items
		assert_equal(DAVAZ::Model::ShopItems, result.class)
		assert_equal(1, result.posters.size)
		assert_equal(1, result.publications.size)
		assert_equal(2, result.films.size)
		assert_equal(1, result.design.size)
		assert_equal(DAVAZ::Model::ShopItem, result.posters.first.class)
		assert_equal('PostersName', result.posters.first.name)
	end
	def test_load_movie
		@manager.load_movie(':slideshow')	
		expected = "SELECT * FROM movies ORDER BY date DESC LIMIT 7"
		assert_equal(expected, @manager.connection.query_str)
	end
	def test_load_movie2
		@manager.load_movie(8)	
		expected = "SELECT * FROM movies WHERE id='8'"
		assert_equal(expected, @manager.connection.query_str)
	end
	def test_insert_guest
		value_hash = {
			:name				=>	'firstname',
			:surname		=>	'lastname',
			:city				=>	'city',
			:country		=>	'country',
			:email			=>	'email',
			:messagetxt	=>	'text',
		}
		expected = "INSERT INTO guestbook VALUES('','#{Time.now.strftime('%Y-%m-%d')}','firstname','lastname','city','country','email','text')"
		@manager.insert_guest(value_hash)
		result = @manager.connection.query_str
		assert_equal(expected, result)
	end
end
