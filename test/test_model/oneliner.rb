#!/usr/bin/env ruby
# TestOneLiner -- davaz.com -- 23.08.2005 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/oneliner'

class TestOneLiner < Test::Unit::TestCase
	def setup
		@oneliner = DAVAZ::OneLiner.new
	end
end
