require 'date'
require 'htmlgrid/spancomposite'
require 'htmlgrid/divcomposite'
require 'htmlgrid/value'
require 'htmlgrid/link'
require 'htmlgrid/div'
require 'view/template'
require 'view/_partial/onload'
require 'view/_partial/list'
require 'util/image_helper'
require 'util/youtube_helper'

module DaVaz::View
  module Works
    class MovieDetails < HtmlGrid::SpanComposite
      COMPONENTS = {
        0 => :year,
        1 => :title,
        2 => :size,
        3 => :location,
        4 => :language
      }
      CSS_MAP = {
        0 => 'movies-details',
        1 => 'movies-details movies-title',
        2 => 'movies-details',
        3 => 'movies-details',
        4 => 'movies-details'
      }
      def year(model)
        date = model.date
        begin
          date = Date.parse(date) unless date.is_a?(Date)
          date.year
        rescue ArgumentError, TypeError
          'n.a.'
        end
      end
    end

    class MovieImage < HtmlGrid::Div
      def init
        super
        img = HtmlGrid::Image.new(:movie_image, @model, @session, self)
        url = DaVaz::Util::ImageHelper.image_url(@model.artobject_id, 'large')
        img.attributes['src']   = url
        img.attributes['width'] = DaVaz.config.medium_image_width
        link = HtmlGrid::HttpLink.new(:url, @model, @session, self)
        link.href  = @model.url
        link.value = img
        link.set_attribute('target', '_blank')
        if @model.url.empty?
          @value = img
        else
          @value = link
        end
      end
    end

    class MovieComment < HtmlGrid::Div
      def init
        super
        comment = @model.text.gsub(/\n/, "[[>>]]")
        comment.gsub!(/<[^>]+>/) do |match|
          match.gsub(/\s+/, '#SPC#')
        end
        comment.gsub!(/ (<\/[^>]+> )/, '\1')
        comment.gsub!(/( <[^>]+>) /, '\1')
        comment_arr = comment.split(' ')
        comment = comment_arr.slice(0, 50).join(' ').gsub(/\[\[>>\]\]/, "\n")
        comment.gsub!(/<[^>]+>/) do |match|
          match.gsub('#SPC#', ' ')
        end
        comment << ' ...' if comment.size > 0
        hpricot = Hpricot(comment, :fixup_tags => true)
        @value = hpricot.to_html
      end
    end

    class GoogleVideoLink < HtmlGrid::Div
      def init
        super
        url = @model.url
        return if url.empty?
        link = HtmlGrid::HttpLink.new(:url, @model, @session, self)
        link.href  = url
        link.value = @lookandfeel.lookup(:watch_movie)
        @value = link
      end
    end

    class MovieEmbed < HtmlGrid::Div
      def init
        super
        video_id = DaVaz::Util::YoutubeHelper.extract_video_id(@model.url)
        return unless video_id
        view_count    = DaVaz::Util::YoutubeHelper.cached_view_count(video_id)
        comment_count = DaVaz::Util::YoutubeHelper.cached_comment_count(video_id)
        stats_parts = []
        stats_parts << DaVaz::Util::YoutubeHelper.format_view_count(view_count)       if view_count
        stats_parts << DaVaz::Util::YoutubeHelper.format_comment_count(comment_count) if comment_count
        stats_html = stats_parts.empty? ? '' : %(<div class="movies-view-count"><span class="movies-view-label">4K:</span> #{stats_parts.join(' &middot; ')}</div>)

        original_id = DaVaz::Util::YoutubeHelper.original_video_id(video_id)
        original_html = ''
        if original_id
          orig_views    = DaVaz::Util::YoutubeHelper.cached_view_count(original_id)
          orig_comments = DaVaz::Util::YoutubeHelper.cached_comment_count(original_id)
          orig_parts = []
          orig_parts << DaVaz::Util::YoutubeHelper.format_view_count(orig_views)       if orig_views
          orig_parts << DaVaz::Util::YoutubeHelper.format_comment_count(orig_comments) if orig_comments
          original_html = %(<div class="movies-view-count movies-view-original"><span class="movies-view-label">Original:</span> #{orig_parts.join(' &middot; ')}</div>) unless orig_parts.empty?
        end

        data_views    = view_count    ? view_count.to_i    : -1
        data_comments = comment_count ? comment_count.to_i : -1
        @value = %(<div class="movies-embed-wrapper" data-views="#{data_views}" data-comments="#{data_comments}" onclick="this.innerHTML='<iframe src=\\'https://www.youtube.com/embed/#{video_id}?autoplay=1\\' frameborder=\\'0\\' allow=\\'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\\' allowfullscreen style=\\'position:absolute;top:0;left:0;width:100%;height:100%\\'></iframe>'"><img src="https://img.youtube.com/vi/#{video_id}/maxresdefault.jpg" alt="#{video_id}" class="movies-embed-thumbnail" style="opacity:0" onerror="_thumbFallback(this)" onload="_checkThumb(this);this.style.opacity=1"><div class="movies-embed-play"></div></div>#{stats_html}#{original_html})
      end
    end

    class MoreLink < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :more_link,
        [0, 1] => :up_link,
      }
      CSS_MAP = {
        0 => 'more-link',
        1 => 'up-link',
      }

      def more_link(model)
        url = @lookandfeel.event_url(:gallery, :ajax_movie_gallery, [
          :artobject_id, model.artobject_id
        ])
        link = HtmlGrid::Link.new(:more, model, @session, self)
        link.href  = 'javascript:void(0);'
        link.value = @lookandfeel.lookup(:more)
        link.set_attribute('name', "#{model.artobject_id}-more")
        link.set_attribute('onclick', <<~EOS)
          showMovieAndShortGallery('movies_gallery_view', 'movies_list', '#{url}');
        EOS
        link
      end

      def up_link(model)
        link = HtmlGrid::Link.new(:site_top, model, @session, self)
        link.href  = @lookandfeel.event_url(:works, :movies, %w{#top})
        link.value = HtmlGrid::Image.new(:icon_toparrow, model, @session, self)
        link
      end
    end

    class MovieComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => MovieDetails,
        [0, 1] => MovieImage,
        [0, 2] => GoogleVideoLink,
        [0, 3] => MovieEmbed,
        [0, 4] => MovieComment,
        [0, 5] => MoreLink,
      }
      CSS_MAP = {
        0 => 'movies-details',
        1 => 'movies-image',
        2 => 'movies-google-link',
        3 => 'movies-embed',
        4 => 'movies-comment',
        5 => 'movies-details-link',
      }

      def movie_details_div(model)
        ''
      end

      def init
        css_id_map.store(5, "movie_details_link_#{@model.artobject_id}")
        css_id_map.store(6, "movie_details_div_#{@model.artobject_id}")
        super
      end
    end

    class MoviesList < HtmlGrid::DivList
      COMPONENTS = {
        [0, 0] => MovieComposite,
      }
      CSS_MAP = {
        0 => 'movies-list-item'
      }
    end

    class MoviesTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(:movies)
        @value = span
      end
    end

    class MoviesSortBar < HtmlGrid::Div
      CSS_CLASS = 'movies-sort-bar'

      def init
        super
        @value = <<~HTML
          <span class="movies-sort-label">Sort:</span>
          <button type="button" class="movies-sort-btn movies-sort-active" data-sort="default">Default</button>
          <button type="button" class="movies-sort-btn" data-sort="views">Most views</button>
          <button type="button" class="movies-sort-btn" data-sort="comments">Most comments</button>
          <script>
          (function() {
            function setup() {
              var list = document.getElementById('movies_list');
              if (!list) return;
              var originalOrder = null;
              function ensureOriginal() {
                if (!originalOrder) originalOrder = Array.prototype.slice.call(list.children);
              }
              function readStat(item, attr) {
                var w = item.querySelector('.movies-embed-wrapper');
                if (!w) return -1;
                var v = parseInt(w.getAttribute('data-' + attr) || '-1', 10);
                return isNaN(v) ? -1 : v;
              }
              function sortBy(mode) {
                ensureOriginal();
                var items;
                if (mode === 'default') {
                  items = originalOrder.slice();
                } else {
                  items = Array.prototype.slice.call(list.children);
                  items.sort(function(a, b) {
                    return readStat(b, mode) - readStat(a, mode);
                  });
                }
                items.forEach(function(el) { list.appendChild(el); });
              }
              var btns = document.querySelectorAll('.movies-sort-btn');
              for (var i = 0; i < btns.length; i++) {
                btns[i].addEventListener('click', function() {
                  var mode = this.getAttribute('data-sort');
                  sortBy(mode);
                  for (var j = 0; j < btns.length; j++) btns[j].classList.remove('movies-sort-active');
                  this.classList.add('movies-sort-active');
                });
              }
            }
            if (document.readyState === 'loading') {
              document.addEventListener('DOMContentLoaded', setup);
            } else {
              setup();
            }
          })();
          </script>
        HTML
      end
    end

    class MoviesComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => MoviesTitle,
        [0, 1] => :movie_top_link,
        [0, 2] => MoviesSortBar,
        [0, 3] => MoviesList,
        [0, 4] => :movies_gallery_view,
        [0, 5] => OnloadMovies,
      }
      CSS_ID_MAP = {
        3 => 'movies_list',
        4 => 'movies_gallery_view',
      }
      CSS_STYLE_MAP = {
        4 => 'display:none;',
      }

      def init
        # Prefetch all YouTube view counts in one batched API call
        movies = @model.respond_to?(:each) ? @model : []
        DaVaz::Util::YoutubeHelper.prefetch_view_counts(movies)
        super
      end

      def movie_top_link(model)
        link = HtmlGrid::Link.new(:nbsp, model, @session, self)
        link.set_attribute('name', 'top')
        link
      end
    end

    class Movies < MoviesTemplate
      CONTENT = MoviesComposite
    end

    class AdminMovies < AdminMoviesTemplate
      CONTENT = MoviesComposite
    end
  end
end
