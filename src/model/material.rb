#!/usr/bin/env ruby
# Model::Material -- davaz.com -- 10.07.2006 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Material
			attr_accessor :material_id, :name
			alias sid material_id
		end
	end
end
