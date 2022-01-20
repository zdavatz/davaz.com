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
    class ShortDetails < HtmlGrid::SpanComposite
      COMPONENTS = {
        0 => :year,
        1 => :title,
        2 => :size,
        3 => :location,
        4 => :language
      }
      CSS_MAP = {
        0 => 'shorts-details',
        1 => 'shorts-details shorts-title',
        2 => 'shorts-details',
        3 => 'shorts-details',
        4 => 'shorts-details'
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

    class ShortImage < HtmlGrid::Div
      def init
        super
        img = HtmlGrid::Image.new(:short_image, @model, @session, self)
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

    class ShortComment < HtmlGrid::Div
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
        link.value = @lookandfeel.lookup(:watch_short)
        @value = link
      end
    end

    class ShortMoreLink < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :more_link,
        [0, 1] => :up_link,
      }
      CSS_MAP = {
        0 => 'more-link',
        1 => 'up-link',
      }

      def more_link(model)
        url = @lookandfeel.event_url(:gallery, :ajax_short_gallery, [
          :artobject_id, model.artobject_id
        ])
        link = HtmlGrid::Link.new(:more, model, @session, self)
        link.href  = 'javascript:void(0);'
        link.value = @lookandfeel.lookup(:more)
        link.set_attribute('name', "#{model.artobject_id}-more")
        link.set_attribute('onclick', <<~EOS)
          showShortGallery('shorts_gallery_view', 'shorts_list', '#{url}');
        EOS
        link
      end

      def up_link(model)
        link = HtmlGrid::Link.new(:site_top, model, @session, self)
        link.href  = @lookandfeel.event_url(:works, :shorts, %w{#top})
        link.value = HtmlGrid::Image.new(:icon_toparrow, model, @session, self)
        link
      end
    end

    class ShortComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => ShortDetails,
        [0, 1] => ShortImage,
        [0, 2] => GoogleVideoLink,
        [0, 3] => ShortComment,
        [0, 4] => ShortMoreLink,
      }
      CSS_MAP = {
        0 => 'shorts-details',
        1 => 'shorts-image',
        2 => 'shorts-google-link',
        3 => 'shorts-comment',
        4 => 'shorts-details-link',
      }

      def short_details_div(model)
        ''
      end

      def init
        css_id_map.store(4, "short_details_link_#{@model.artobject_id}")
        css_id_map.store(5, "short_details_div_#{@model.artobject_id}")
        super
      end
    end

    class ShortsList < HtmlGrid::DivList
      COMPONENTS = {
        [0, 0] => ShortComposite,
      }
      CSS_MAP = {
        0 => 'shorts-list-item'
      }
    end

    class ShortsTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(:shorts)
        @value = span
      end
    end

    class ShortsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => ShortsTitle,
        [0, 1] => :short_top_link,
        [0, 2] => ShortsList,
        [0, 3] => :shorts_gallery_view,
        [0, 4] => OnloadShorts,
      }
      CSS_ID_MAP = {
        2 => 'shorts_list',
        3 => 'shorts_gallery_view',
      }
      CSS_STYLE_MAP = {
        3 => 'display:none;',
      }

      def short_top_link(model)
        link = HtmlGrid::Link.new(:nbsp, model, @session, self)
        link.set_attribute('name', 'top')
        link
      end
    end

    class Shorts < ShortsTemplate
      CONTENT = ShortsComposite
    end

    class AdminShorts < AdminShortsTemplate
      CONTENT = ShortsComposite
    end
  end
end
