#!/usr/bin/env ruby
# State::Works::RackState -- davaz.com -- 04.07.2006 -- mhuggler@ywesee.com

module DAVAZ
	module State
		module Works
class RackState < State::Works::Global
	ARTGROUP_ID = nil
	def init
		@model = OpenStruct.new
		serie_id = @session.user_input(:serie_id) 
		series = @session.app.load_series_by_artgroup(artgroup_id)
		@model.series = series
		if(serie_id.nil?)
			unless(series.empty?)
				serie_id = series.first.serie_id
			end
		end
		@model.serie_id = serie_id
		args = [ 
			[ :serie_id, serie_id], 
			[ :artgroup_id, artgroup_id], 
		]
		url = @session.lookandfeel.event_url(:gallery, :ajax_rack, 
																				 args) 
		@model.serie_items = {
			'artObjectIds'	=>	[],
			'images'	=>	[],
			'titles'	=>	[],
			'dataUrl'	=>	url,
			'serieId'	=>	serie_id,
		}
		serie_items = @session.app.load_serie(serie_id).artobjects
		serie_items.each { |item|
			if(Util::ImageHelper.has_image?(item.artobject_id))
				image = Util::ImageHelper.image_path(item.artobject_id, 'slideshow')
				@model.serie_items['artObjectIds'].push(item.artobject_id)
				@model.serie_items['images'].push(image)
				@model.serie_items['titles'].push(item.title)
			end
		}
	end
	def artgroup_id
		self.class.const_get(:ARTGROUP_ID)
	end
end
		end
	end
end
