require 'json'
require 'htmlgrid/divcomposite'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/urllink'
require 'htmlgrid/div'
require 'view/_partial/form'
require 'view/_partial/oneliner'
require 'view/_partial/ticker'
require 'view/_partial/maillink'
require 'view/template'
require 'util/youtube_helper'

module DaVaz::View
  module Personal

    class IntroText < HtmlGrid::Div
      CSS_CLASS = "intro-text"

      def init
        super
        @value = @lookandfeel.lookup(:intro_text)
      end
    end

    class Signature < HtmlGrid::Div
      CSS_CLASS = 'signature'

      def init
        super
        img = HtmlGrid::Image.new(:signature, model, @session, self)
        link = HtmlGrid::Link.new(:signature, model, @session, self)
        link.href  = @lookandfeel.event_url(:personal, :work)
        link.value = img
        @value = link
      end
    end

    class Photo < HtmlGrid::Div
      CSS_CLASS = 'photo'
      CSS_ID    = 'photo_davaz'

      def init
        super
        img = HtmlGrid::Image.new(:photo_davaz, model, @session, self)
        img.set_attribute(
          :href,  # previous artobject_id 1591 is missing
          @lookandfeel.event_url(:tooltip, :tooltip, [:artobject_id, 1500])
        )
        img.css_id = 'davaz'
        @value = img
      end
    end

    class PicInspiration < HtmlGrid::Div
      CSS_CLASS = 'pic-inspiration'

      def init
        super
        img = HtmlGrid::Image.new(:pic_inspiration, model, @session, self)
        link = HtmlGrid::Link.new(:pic_inspiration, model, @session, self)
        link.href  = @lookandfeel.event_url(:personal, :inspiration)
        link.value = img
        @value = link
      end
    end

    class PicFamily < HtmlGrid::Div
      CSS_CLASS = 'pic-family'

      def init
        super
        img = HtmlGrid::Image.new(:pic_family, model, @session, self)
        link = HtmlGrid::Link.new(:pic_family, model, @session, self)
        link.href  = @lookandfeel.event_url(:personal, :family)
        link.value = img
        @value = link
      end
    end

    class PicBottleneck < HtmlGrid::Div
      CSS_CLASS = 'pic-bottleneck'
      CSS_ID    = 'pic_bottleneck'

      def init
        super
        img = HtmlGrid::Image.new(:pic_bottleneck, model, @session, self)
        img.set_attribute(
          :href,
          @lookandfeel.event_url(:tooltip, :tooltip, [:title, 'Bottleneck'])
        )
        img.css_id = 'bottleneck'
        @value = img
      end
    end

    class Copyright < HtmlGrid::Div
      CSS_CLASS = 'init-copyright'

      def init
        super
        link = HtmlGrid::HttpLink.new(:copyright, model, @session, self)
        link.href      = @lookandfeel.lookup(:ywesee_url)
        link.css_class = 'copyright-link'
        @value = link
      end
    end

    class CommunicationLinksComposite < HtmlGrid::Composite
      LEGACY_INTERFACE = false
      CSS_CLASS  = 'communication-links'
      COMPONENTS = {
        [0, 0] => :blog,
        [0, 1] => :news,
        [0, 2] => :links,
        [0, 3] => :email,
        [0, 4] => :gallery,
        [0, 5] => :movies,
        [0, 6] => :guestbook,
        [0, 7] => :shorts,
        [0, 8] => :clips
      }
      CSS_MAP = {
        [0, 0, 1, 9] => 'communication-links',
      }

      def blog(model)
        link = HtmlGrid::Link.new(:blog, model, @session, self)
        link.href      = 'http://davaz.wordpress.com'
        link.css_class = 'communication-link'
        link
      end

      def news(model)
        link = HtmlGrid::Link.new(:news, model, @session, self)
        link.href      = @lookandfeel.event_url(:communication, :news)
        link.css_class = 'communication-link'
        link
      end

      def links(model)
        link = HtmlGrid::Link.new(:links, model, @session, self)
        link.href      = @lookandfeel.event_url(:communication, :links)
        link.css_class = 'communication-link'
        link
      end

      def email(model)
        link = MailLink.new(:contact_email, model, @session, self)
        link.mailto    = @lookandfeel.lookup(:email_juerg)
        link.css_class = 'communication-link'
        link
      end

      def gallery(model)
        link = HtmlGrid::Link.new(:gallery, model, @session, self)
        link.href      = @lookandfeel.event_url(:gallery, :gallery)
        link.css_class = 'communication-link'
        link
      end

      def movies(model)
        link = HtmlGrid::Link.new(:movies, model, @session, self)
        link.href      = @lookandfeel.event_url(:works, :movies)
        link.css_class = 'communication-link'
        link
      end

      def guestbook(model)
        link = HtmlGrid::Link.new(:guestbook, model, @session, self)
        link.href      = @lookandfeel.event_url(:communication, :guestbook)
        link.css_class = 'communication-link'
        link
      end

      def shorts(model)
        link = HtmlGrid::Link.new(:shorts, model, @session, self)
        link.href      = @lookandfeel.event_url(:works, :shorts)
        link.css_class = 'communication-link'
        link
      end

      def clips(model)
        link = HtmlGrid::Link.new(:clips, model, @session, self)
        link.href      = @lookandfeel.event_url(:works, :clips)
        link.css_class = 'communication-link'
        link
      end
    end

    class MoviePage < HtmlGrid::Div
      CSS_CLASS = 'movie-page display-inline'

      def init
        super
        link = HtmlGrid::Link.new(:movie_page, model, @session, self)
        link.href      = @lookandfeel.event_url(:works, :movies)
        link.value     = @lookandfeel.lookup(:movie_page)
        link.css_class = 'movie-page'
        @value = link
      end
    end

    class MovieLinks < HtmlGrid::DivComposite
      CSS_CLASS  = 'movie-links'
      COMPONENTS = {
        [0, 0] => :movie_ticker_link,
        [1, 0] => :movie_page,
      }

      def movie_ticker_link(model)
        link = HtmlGrid::Link.new(:movie_ticker, model, @session, self)
        self.onload    = link.attributes['onclick'] = 'toggleTicker();'
        link.href      = 'javascript:void(0)'
        link.value     = @lookandfeel.lookup(:movie_link)
        link.css_class = 'movies-div-link'
        link
      end

      def movie_page(model)
        link = HtmlGrid::Link.new(:movie_page, model, @session, self)
        link.href      = @lookandfeel.event_url(:works, :movies)
        link.value     = @lookandfeel.lookup(:movie_page)
        link.css_class = 'movie-page'
        link
      end
    end

    class CommunicationLinks < HtmlGrid::DivComposite
      CSS_CLASS  = 'communication-links'
      COMPONENTS = {
        [0, 0] => CommunicationLinksComposite,
      }
    end

    class Drawing < HtmlGrid::DivComposite
      CSS_CLASS = "drawing"
      COMPONENTS = {
        [0, 0] => :drawing,
      }
      def drawing(model)
        HtmlGrid::Image.new(:init_drawing, model, @session, self)
      end
    end

    class PayPalForm < Form
      COMPONENTS = {
        [0, 0] => :donation_logo,
      }
      FORM_ACTION = 'https://www.paypal.com/cgi-bin/webscr'

      def donation_logo(model)
        image = HtmlGrid::Input.new(:submit, model, @session, self)
        image.attributes['src']    = @lookandfeel.resource(:paypal_donate)
        image.attributes['type']   = 'image'
        image.attributes['border'] = '0'
        image.attributes['alt']    = "Make payments with PayPal " \
                                     "- it's fast, free and secure!"
        image
      end

      def hidden_fields(context)
        '' <<
        context.hidden('cmd', '_xclick')<<
        context.hidden('business', 'juerg@davaz.com')<<
        context.hidden('item_name','Donation For The Da Vaz Foundation.')<<
        context.hidden('no_note','1')<<
        context.hidden('currency_code', 'EUR')<<
        context.hidden('tax', '0')<<
        context.hidden('lc','US')<<
        context.hidden('bn','PP-DonationsBF')
      end
    end

    class PayPalButtonDiv < HtmlGrid::DivComposite
      CSS_ID     = 'paypal_button'
      COMPONENTS = {
        [0, 0] => PayPalForm,
      }
    end

    class PayPalDiv < HtmlGrid::DivComposite
      CSS_ID     = 'paypal'
      COMPONENTS = {
        [0, 0] => PayPalButtonDiv,
      }
    end

    class VideoThumbnailGrid < HtmlGrid::Div
      def init
        super
        videos = @model.respond_to?(:each) ? @model.to_a : []
        video_data = videos.filter_map { |v|
          video_id = DaVaz::Util::YoutubeHelper.extract_video_id(v.url)
          next unless video_id
          thumb = DaVaz::Util::YoutubeHelper.clip_thumbnail_url(v.url)
          thumb ||= "https://img.youtube.com/vi/#{video_id}/maxresdefault.jpg"
          { id: video_id, url: v.url, title: (v.title || '').gsub('"', '&quot;').gsub("'", '&#39;'), thumb: thumb }
        }
        return if video_data.empty?

        section = self.class.const_get(:SECTION)
        grid_id = "video_thumbs_#{section}"
        queue_var = "_videoQueue_#{section}"
        loading_var = "_videoLoading_#{section}"
        status_id = "video_thumb_status_#{section}"
        label = @lookandfeel.lookup(section.to_sym) || section.capitalize

        initial = video_data.first(10)
        remaining = video_data.drop(10)

        html = %(<h3 class="video-section-title">#{label} (#{video_data.length})</h3>)
        html << %(<div id="#{grid_id}" class="video-thumb-grid">)
        initial.each do |v|
          html << thumb_html(v)
        end
        html << '</div>'

        json_remaining = remaining.map { |v| [v[:id], v[:url], v[:title], v[:thumb]] }
        html << <<~SCRIPT
          <script type="text/javascript">
          var #{queue_var} = #{json_remaining.to_json};
          var #{loading_var} = false;
          function _loadMore_#{section}() {
            if (#{loading_var} || #{queue_var}.length === 0) return;
            #{loading_var} = true;
            var grid = document.getElementById('#{grid_id}');
            var batch = #{queue_var}.splice(0, 10);
            for (var i = 0; i < batch.length; i++) {
              var v = batch[i];
              var a = document.createElement('a');
              a.href = v[1]; a.target = '_blank';
              a.className = 'video-thumb-link';
              a.title = v[2];
              var img = document.createElement('img');
              img.src = v[3] || ('https://img.youtube.com/vi/' + v[0] + '/maxresdefault.jpg');
              img.alt = v[2]; img.className = 'video-thumb-img';
              img.onload = function() { _checkThumb(this); };
              img.onerror = function() { this.parentNode.remove(); };
              a.appendChild(img); grid.appendChild(a);
            }
            #{loading_var} = false;
            if (#{queue_var}.length === 0) {
              var msg = document.getElementById('#{status_id}');
              if (msg) msg.style.display = 'none';
            }
          }
          window.addEventListener('scroll', function() {
            var grid = document.getElementById('#{grid_id}');
            if (!grid) return;
            if (grid.getBoundingClientRect().bottom < window.innerHeight + 300) {
              _loadMore_#{section}();
            }
          });
          </script>
        SCRIPT
        remaining_count = remaining.size
        if remaining_count > 0
          html << %(<div id="#{status_id}" class="video-thumb-status">Scroll for more (#{remaining_count} remaining)</div>)
        end
        @value = html
      end

      private

      def thumb_html(v)
        %(<a href="#{v[:url]}" target="_blank" class="video-thumb-link" title="#{v[:title]}"><img src="#{v[:thumb]}" alt="#{v[:title]}" class="video-thumb-img" onload="_checkThumb(this)" onerror="this.parentNode.remove()"></a>)
      end
    end

    class VideoMoviesGrid < VideoThumbnailGrid
      SECTION = 'movies'
    end

    class VideoShortsGrid < VideoThumbnailGrid
      SECTION = 'shorts'
    end

    class VideoClipsGrid < VideoThumbnailGrid
      SECTION = 'clips'
    end

    class InitComposite < HtmlGrid::DivComposite
      CSS_CLASS = 'init-container'
      COMPONENTS = {
        [ 0, 0] => Drawing,
        [ 1, 0] => Photo,
        [ 2, 0] => Signature,
        [ 3, 0] => IntroText,
        [ 4, 0] => PicInspiration,
        [ 5, 0] => PicFamily,
        [ 6, 0] => PicBottleneck,
        [ 7, 0] => CommunicationLinks,
        [ 9, 0] => component(Oneliner, :oneliner),
        [10, 0] => MovieLinks,
      }

      def init
        super
        self.onload = <<~EOS.gsub(/\n|^\s*/, '')
          (function() {
            setHrefTooltip('photo_davaz',
              'davaz', 'art', ['below-alt']);
            setHrefTooltip('pic_bottleneck',
              'bottleneck', 'bottleneck', ['below-alt']);
          })();
        EOS
      end
    end

    # _thumbFallback and _checkThumb are defined in davaz.js (global)
    class CheckThumbScript < HtmlGrid::Div
      def init
        super
        @value = ''
      end
    end

    class Init < Template
      CSS_FILES = [ :navigation_css, :init_css ]
      COMPONENTS = {
        [0, 0] => TopNavigation,
        [0, 1] => component(Ticker, :movies),
        [0, 2] => InitComposite,
        [0, 3] => CheckThumbScript,
        [0, 4] => component(VideoClipsGrid, :video_clips),
        [0, 5] => component(VideoShortsGrid, :video_shorts),
        [0, 6] => component(VideoMoviesGrid, :video_movies),
        [0, 7] => PayPalDiv,
      }
      CSS_ID_MAP = {
        0 => 'top_navigation',
        1 => 'ticker_container',
      }
      CSS_STYLE_MAP = {
        1 => 'display: none',
      }
      CSS_MAP = {}
    end
  end
end
