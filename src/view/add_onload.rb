#!/usr/bin/env ruby
# View::AddOnloadShow -- davaz.com -- 05.07.2006 -- mhuggler@ywesee.com

require 'htmlgrid/javascript'

module DAVAZ
	module View
		class AddOnloadShow < HtmlGrid::JavaScript
			def add_location_hash
				if(@model.serie_id)
					script = <<-EOS
						location.hash = 'Rack_#{@model.serie_id}';
						var serieLink = dojo.byId('#{@model.serie_id}');
						serieLink.className += ' active';
					EOS
				else
					""
				end
			end
			def init
				args = [ :serie_id, nil ]
				url = @lookandfeel.event_url(:gallery, :ajax_rack, args)
				script = <<-EOS
					dojo.addOnLoad(function() {
						var bookmarkId = location.hash;
						if(bookmarkId){
							bookmarkId = bookmarkId.substring(1, bookmarkId.length);
							var show_type = bookmarkId.split('_')[0];
							var serie_id = bookmarkId.split('_')[1];
							var artobject_id = bookmarkId.split('_')[2];
							if(artobject_id) {
								var url = '#{url}' + serie_id + '/artobject_id/' + artobject_id;
								toggleShow('show', url, show_type, 'upper-search-composite', serie_id, artobject_id);
							} else {
								toggleShow('show', '#{url}' + serie_id, show_type, 'upper-search-composite', serie_id);
							}
						}	else {
							#{add_location_hash}
						}
					})
				EOS
				@value = script
			end
		end
		class AddOnloadMovies < HtmlGrid::JavaScript
			def init
				replace_id = "movies-list"
				div_id = "movies-gallery-view"
				args = [
					:artobject_id, ""
				]
				url = @lookandfeel.event_url(:gallery, :ajax_movie_gallery, args)
				script = <<-EOS
					dojo.addOnLoad(function() {
						var artobjectId = location.hash;
						if(artobjectId && artobjectId != '#top'){
							artobjectId = artobjectId.substring(1, artobjectId.length);
							var url = '#{url}' + artobjectId
							showMovieGallery('#{div_id}', '#{replace_id}', url)
						}
					})
				EOS
				@value = script
			end
		end
	end
end
