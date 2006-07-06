#!/usr/bin/env ruby
# View::AddOnloadRack -- davaz.com -- 05.07.2006 -- mhuggler@ywesee.com

require 'htmlgrid/javascript'

module DAVAZ
	module View
		class AddOnloadShow < HtmlGrid::JavaScript
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
							toggleShow('show', '#{url}' + serie_id, show_type, 'upper-search-composite', serie_id);
						}	
					})
				EOS
				@value = script
			end
		end
	end
end
