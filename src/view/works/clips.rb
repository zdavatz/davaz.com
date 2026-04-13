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
    class ClipDetails < HtmlGrid::SpanComposite
      COMPONENTS = {
        0 => :year,
        1 => :title,
        2 => :size,
        3 => :location,
        4 => :language
      }
      CSS_MAP = {
        0 => 'clips-details',
        1 => 'clips-details clips-title',
        2 => 'clips-details',
        3 => 'clips-details',
        4 => 'clips-details'
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

    class ClipImage < HtmlGrid::Div
      def init
        super
        img = HtmlGrid::Image.new(:clip_image, @model, @session, self)
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

    class ClipComment < HtmlGrid::Div
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

    class ClipVideoLink < HtmlGrid::Div
      def init
        super
        url = @model.url
        return if url.empty?
        link = HtmlGrid::HttpLink.new(:url, @model, @session, self)
        link.href  = url
        link.value = @lookandfeel.lookup(:watch_clip)
        @value = link
      end
    end

    class ClipEmbed < HtmlGrid::Div
      def init
        super
        video_id = DaVaz::Util::YoutubeHelper.extract_video_id(@model.url)
        return unless video_id
        view_count = DaVaz::Util::YoutubeHelper.cached_view_count(video_id)
        views_html = if view_count
          %(<div class="clips-view-count">#{DaVaz::Util::YoutubeHelper.format_view_count(view_count)}</div>)
        else
          ''
        end
        @value = %(<div class="clips-embed-wrapper" onclick="this.innerHTML='<iframe src=\\'https://www.youtube.com/embed/#{video_id}?autoplay=1\\' frameborder=\\'0\\' allow=\\'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\\' allowfullscreen style=\\'position:absolute;top:0;left:0;width:100%;height:100%\\'></iframe>'"><img src="https://img.youtube.com/vi/#{video_id}/hqdefault.jpg" alt="#{video_id}" class="clips-embed-thumbnail"><div class="clips-embed-play"></div></div>#{views_html})
      end
    end

    class ClipMoreLink < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :more_link,
        [0, 1] => :up_link,
      }
      CSS_MAP = {
        0 => 'more-link',
        1 => 'up-link',
      }

      def more_link(model)
        url = @lookandfeel.event_url(:gallery, :ajax_clip_gallery, [
          :artobject_id, model.artobject_id
        ])
        link = HtmlGrid::Link.new(:more, model, @session, self)
        link.href  = 'javascript:void(0);'
        link.value = @lookandfeel.lookup(:more)
        link.set_attribute('name', "#{model.artobject_id}-more")
        link.set_attribute('onclick', <<~EOS)
          showMovieAndShortGallery('clips_gallery_view', 'clips_list', '#{url}');
        EOS
        link
      end

      def up_link(model)
        link = HtmlGrid::Link.new(:site_top, model, @session, self)
        link.href  = @lookandfeel.event_url(:works, :clips, %w{#top})
        link.value = HtmlGrid::Image.new(:icon_toparrow, model, @session, self)
        link
      end
    end

    class ClipComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => ClipDetails,
        [0, 1] => ClipImage,
        [0, 2] => ClipVideoLink,
        [0, 3] => ClipEmbed,
        [0, 4] => ClipComment,
        [0, 5] => ClipMoreLink,
      }
      CSS_MAP = {
        0 => 'clips-details',
        1 => 'clips-image',
        2 => 'clips-google-link',
        3 => 'clips-embed',
        4 => 'clips-comment',
        5 => 'clips-details-link',
      }

      def init
        css_id_map.store(5, "clip_details_link_#{@model.artobject_id}")
        css_id_map.store(6, "clip_details_div_#{@model.artobject_id}")
        super
      end
    end

    class ClipsList < HtmlGrid::DivList
      COMPONENTS = {
        [0, 0] => ClipComposite,
      }
      CSS_MAP = {
        0 => 'clips-list-item'
      }
    end

    class ClipsTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(:clips)
        @value = span
      end
    end

    class ClipsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => ClipsTitle,
        [0, 1] => :clip_top_link,
        [0, 2] => ClipsList,
        [0, 3] => :clips_gallery_view,
        [0, 4] => OnloadClips,
      }
      CSS_ID_MAP = {
        2 => 'clips_list',
        3 => 'clips_gallery_view',
      }
      CSS_STYLE_MAP = {
        3 => 'display:none;',
      }

      def init
        clips = @model.respond_to?(:each) ? @model : []
        DaVaz::Util::YoutubeHelper.prefetch_view_counts(clips)
        super
      end

      def clip_top_link(model)
        link = HtmlGrid::Link.new(:nbsp, model, @session, self)
        link.set_attribute('name', 'top')
        link
      end
    end

    class Clips < ClipsTemplate
      CONTENT = ClipsComposite
    end
  end
end
