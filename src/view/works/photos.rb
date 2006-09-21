#!/usr/bin/env ruby
# View::Works::Photos -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/works/works'

module DAVAZ
	module View
		module Works
class PhotosComposite < View::Works::Works; end
class Photos < View::PhotosPublicTemplate
	CONTENT = View::Works::PhotosComposite 
end
class AdminPhotos < View::AdminPhotosPublicTemplate
	CONTENT = View::Works::PhotosComposite 
end
		end
	end
end
