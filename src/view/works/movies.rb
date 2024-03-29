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
        [0, 3] => MovieComment,
        [0, 4] => MoreLink,
      }
      CSS_MAP = {
        0 => 'movies-details',
        1 => 'movies-image',
        2 => 'movies-google-link',
        3 => 'movies-comment',
        4 => 'movies-details-link',
      }

      def movie_details_div(model)
        ''
      end

      def init
        css_id_map.store(4, "movie_details_link_#{@model.artobject_id}")
        css_id_map.store(5, "movie_details_div_#{@model.artobject_id}")
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

    class MoviesComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => MoviesTitle,
        [0, 1] => :movie_top_link,
        [0, 2] => MoviesList,
        [0, 3] => :movies_gallery_view,
        [0, 4] => OnloadMovies,
      }
      CSS_ID_MAP = {
        2 => 'movies_list',
        3 => 'movies_gallery_view',
      }
      CSS_STYLE_MAP = {
        3 => 'display:none;',
      }

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
