#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'util/validator'

class TestValidator < Minitest::Test

  def setup
  end

  def test_validate_article
    key = :article
    value = {"111"=>"", "112"=>"", "113"=>"2", "114"=>"2", "115"=>""}
    validator = DaVaz::Util::Validator.new
    assert(validator.validate(key, value), ":article must be valid")
  end

end