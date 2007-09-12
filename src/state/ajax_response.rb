#!/usr/bin/env ruby
# State::AjaxResponse -- Davaz -- 06.09.2007 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/ajax_response'

module DAVAZ
  module State
    class AjaxResponse < Global
      VOLATILE = true
      VIEW = View::AjaxResponse
    end
  end
end
