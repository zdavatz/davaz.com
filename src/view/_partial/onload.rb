require 'htmlgrid/javascript'

module DaVaz::View
  class OnloadShow < HtmlGrid::JavaScript
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
      url = @lookandfeel.event_url(:gallery, :ajax_rack, [
        [:serie_id, nil]
      ])
      self.onload = <<~EOS.gsub(/\n|^\s*/, '')
        (function() {
          if (location.hash == '') {
            #{add_location_hash}
          }
          var bookmarkId = location.hash;
          if (bookmarkId) {
            bookmarkId = bookmarkId.substring(1, bookmarkId.length);
            var showType    = bookmarkId.split('_')[0]
              , serieId     = bookmarkId.split('_')[1]
              , artobjectId = bookmarkId.split('_')[2]
              ;
            var url = '#{url}' + serieId;
            if (artobjectId) {
              url += '/artobject_id/' + artobjectId;
              toggleShow('show', url, showType,
                'show_wipearea', serieId, artobjectId);
            } else {
              toggleShow('show', url, showType,
                'show_wipearea', serieId);
            }
          }  else {
            #{add_location_hash}
          }
        })();
      EOS
    end
  end

  class OnloadMovies < HtmlGrid::JavaScript
    def init
      url = @lookandfeel.event_url(:gallery, :ajax_movie_gallery, [
        :artobject_id, ''
      ])
      @value = <<-EOS
        dojo.addOnLoad(function() {
          var artobjectId = location.hash;
          if (artobjectId && artobjectId != '#top') {
            artobjectId = artobjectId.substring(1, artobjectId.length);
            var url = '#{url}' + artobjectId;
            showMovieAndShortGallery('movies_gallery_view', 'movies_list', url);
          }
        })
      EOS
    end
  end

  class OnloadShorts < HtmlGrid::JavaScript
    def init
      url = @lookandfeel.event_url(:gallery, :ajax_short_gallery, [
        :artobject_id, ''
      ])
      @value = <<-EOS
        dojo.addOnLoad(function() {
          var artobjectId = location.hash;
          if (artobjectId && artobjectId != '#top') {
            artobjectId = artobjectId.substring(1, artobjectId.length);
            var url = '#{url}' + artobjectId;
            showMovieAndShortGallery('shorts_gallery_view', 'shorts_list', url);
          }
        })
      EOS
    end
  end
end
