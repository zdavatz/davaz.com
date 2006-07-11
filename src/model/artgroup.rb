#!/usr/bin/env ruby
# Model::Artgroup -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Artgroup
			attr_accessor :artgroup_id, :name, :shop_order
			alias sid artgroup_id
		end
	end
end
