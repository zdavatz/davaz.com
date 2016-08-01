require 'htmlgrid/javascript'

module DaVaz
  module View
    class AddOnloadShow < HtmlGrid::JavaScript
      def default_location_hash
        "Rack_#{@model.serie_id}"
      end

      def add_location_hash
        return '' unless @model.serie_id
        <<~EOS
          location.hash = '#{default_location_hash}';
          var serieLink = document.getElementById('#{@model.serie_id}');
          serieLink.className += ' active';
        EOS
      end

      def init
        url = @lookandfeel.event_url(:gallery, :ajax_rack, [:serie_id, nil])
        self.onload = <<~EOS
          (function() {
            if (location.hash == '') {
              #{add_location_hash}
            }
            var bookmarkId = location.hash;
            if (bookmarkId) {
              bookmarkId = bookmarkId.substring(1, bookmarkId.length);
              var show_type    = bookmarkId.split('_')[0]
                , serie_id     = bookmarkId.split('_')[1]
                , artobject_id = bookmarkId.split('_')[2]
                ;
              var url = '#{url}' + serie_id;
              if (artobject_id) {
                url += '/artobject_id/' + artobject_id;
                toggleShow('show', url, show_type,
                  'show_wipearea', serie_id, artobject_id);
              } else {
                toggleShow('show', url, show_type,
                  'show_wipearea', serie_id);
              }
            }  else {
              #{add_location_hash}
            }
          })();
        EOS
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
