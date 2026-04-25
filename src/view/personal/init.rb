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
          { id: video_id, url: v.url, title: (v.title || '').gsub('"', '&quot;').gsub("'", '&#39;'), thumb: thumb, text: (v.text || '').to_s }
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

        # Build full index of all videos for search (id, url, title, thumb, text)
        all_json = video_data.map { |v| [v[:id], v[:url], v[:title], v[:thumb], v[:text]] }

        html = %(<h3 class="video-section-title" id="video_title_#{section}">#{label} (#{video_data.length})</h3>)
        html << %(<div id="#{grid_id}" class="video-thumb-grid">)
        initial.each do |v|
          html << thumb_html(v)
        end
        html << '</div>'

        json_remaining = remaining.map { |v| [v[:id], v[:url], v[:title], v[:thumb], v[:text]] }
        html << <<~SCRIPT
          <script type="text/javascript">
          var #{queue_var} = #{json_remaining.to_json};
          var _videoAll_#{section} = #{all_json.to_json};
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

    class VideoSearchBar < HtmlGrid::Div
      # Curated tags that always appear in the cloud, even if the words
      # aren't in any video title. The search query matches title OR
      # description, so terms that only appear in descriptions still find
      # their videos. Format: [display label, search query].
      PROMOTED_TAGS = [
        ['Prix de Bâle', 'prix de bâle'],
        ['pig',          'pig'],
        ['bear',         'bear'],
        ['fucking E',    'fucking english'],
        ['penis',        'penis'],
        ['kisses',       'kisses'],
        ['thinking',     'thinking'],
        ['bi öis',       'bi öis'],
        ['hand',         'hand'],
        ['curiosity',    'curiosity'],
      ].freeze

      STOPWORDS = %w[
        the and for with from this that these those have has had been being was were
        you your his her their our its who what when where why how can but not all any
        out too very just some more than then also about into over only one two three
        four five six seven eight nine ten first last next here there each every
        der die das den dem des ein eine einen einem einer eines und oder aber doch
        ist sind war waren sein werden wurde wurden haben hatte hatten hat als auch
        mit ohne von zum zur nach bei aus auf für ueber fuer unter vor gegen zwischen
        ich wir ihr mir mich dir dich ihm ihn ihnen uns euch schon noch nur nicht
        kein keine keiner keines keinem keinen sich sie ihn ihm beim ins
        il lo la gli le un uno una dei delle dello della degli
        che come quando dove perche con senza per tra fra contro sopra sotto
        sono sei siamo siete erano era dal dalla alle allo della sulla
        www http https com org net ch html php www2 youtu tube watch video
        enhanced
      ].to_set.freeze

      def build_tag_cloud(videos, limit = 40)
        counts = Hash.new(0)
        display = {}
        videos.each do |v|
          next if v.title.nil? || v.title.strip.empty?
          v.title.scan(/[\p{L}\p{N}]+/).each do |tok|
            key = tok.downcase
            next if key.length < 3
            next if key =~ /\A\d+\z/
            next if STOPWORDS.include?(key)
            counts[key] += 1
            display[key] ||= tok
          end
        end
        counts.sort_by { |_, c| -c }.first(limit).map { |k, c| [display[k], k, c] }
      end

      def active_promoted_tags(videos)
        haystacks = videos.map { |v|
          t = v.title.to_s.downcase
          d = v.respond_to?(:text) ? v.text.to_s.downcase : ''
          [t, d]
        }
        self.class::PROMOTED_TAGS.select { |_label, query|
          q = query.downcase
          haystacks.any? { |t, d| t.include?(q) || d.include?(q) }
        }
      end

      def render_tag_cloud(tags, promoted_tags = self.class::PROMOTED_TAGS)
        return '' if tags.empty? && promoted_tags.empty?
        max = tags.first ? tags.first[2] : 1
        min = tags.last  ? tags.last[2]  : 1
        spread = [max - min, 1].max.to_f
        promoted = promoted_tags.map { |label, query|
          safe_label = label.gsub('&', '&amp;').gsub('<', '&lt;').gsub('"', '&quot;')
          safe_query = query.gsub('&', '&amp;').gsub('<', '&lt;').gsub('"', '&quot;')
          %(<span class="video-tag video-tag-promoted" data-tag="#{safe_query}">#{safe_label}</span>)
        }
        derived = tags.map { |word, key, count|
          scale = (count - min) / spread
          size  = (0.8 + scale * 0.7).round(2)
          label = word.gsub('&', '&amp;').gsub('<', '&lt;').gsub('"', '&quot;')
          %(<span class="video-tag" data-tag="#{key}" style="font-size:#{size}rem" title="#{count} matches">#{label}</span>)
        }
        result = derived.dup
        unless promoted.empty?
          n_p = promoted.size
          n_d = derived.size
          positions = (0...n_p).map { |i| ((i + 1).to_f * (n_d + 1) / (n_p + 1)).round }
          promoted.zip(positions).reverse_each do |tag, pos|
            result.insert(pos, tag)
          end
        end
        spans = result.join(' ')
        %(<div id="video_tag_cloud" class="video-tag-cloud">#{spans}</div>)
      end

      def init
        super
        all_videos = []
        %i[video_movies video_shorts video_clips].each do |attr|
          val = @model.respond_to?(attr) ? @model.send(attr) : nil
          all_videos.concat(val.to_a) if val
        end
        tags = build_tag_cloud(all_videos, 40)
        promoted = active_promoted_tags(all_videos)

        @value = <<~HTML
          #{render_tag_cloud(tags, promoted)}
          <div id="video_search_bar" class="video-search-bar">
            <input type="text" id="video_search_input" placeholder="Search, e.g. nt" autocomplete="off">
            <span id="video_search_count" class="video-search-count"></span>
          </div>
          <script type="text/javascript">
          (function() {
            var sections = ['clips', 'shorts', 'movies'];
            var input = document.getElementById('video_search_input');
            var countEl = document.getElementById('video_search_count');
            if (!input) return;

            // Rotating placeholder samples to hint at searchable content
            var samples = ['nt', 'chick', 'pi', 'Georgien', 'lim', 'sib', 'visu', 'last', 'uni', 'li', 'com', 'mo', 'Kazakh'];
            var sampleIdx = 0;
            input.placeholder = 'Search, e.g. ' + samples[0];
            var rotator = setInterval(function() {
              if (input.value !== '' || document.activeElement === input) return;
              sampleIdx = (sampleIdx + 1) % samples.length;
              input.placeholder = 'Search, e.g. ' + samples[sampleIdx];
            }, 2000);

            function makeThumb(v) {
              var a = document.createElement('a');
              a.href = v[1]; a.target = '_blank';
              a.className = 'video-thumb-link';
              a.title = v[2];
              var img = document.createElement('img');
              img.src = v[3] || ('https://img.youtube.com/vi/' + v[0] + '/maxresdefault.jpg');
              img.alt = v[2]; img.className = 'video-thumb-img';
              img.onload = function() { _checkThumb(this); };
              img.onerror = function() { this.parentNode.remove(); };
              a.appendChild(img);
              return a;
            }

            function doSearch() {
              var q = input.value.trim().toLowerCase();
              var totalMatches = 0;
              for (var s = 0; s < sections.length; s++) {
                var sec = sections[s];
                var all = window['_videoAll_' + sec];
                var grid = document.getElementById('video_thumbs_' + sec);
                var title = document.getElementById('video_title_' + sec);
                var status = document.getElementById('video_thumb_status_' + sec);
                if (!all || !grid) continue;

                if (q === '') {
                  // Not searching — show section as-is (already rendered)
                  if (title) { title.style.display = ''; }
                  if (status) { status.style.display = ''; }
                  // Only restore if we previously filtered
                  if (grid.getAttribute('data-filtered') === '1') {
                    grid.innerHTML = '';
                    grid.removeAttribute('data-filtered');
                    var initial = all.slice(0, 10);
                    for (var i = 0; i < initial.length; i++) {
                      grid.appendChild(makeThumb(initial[i]));
                    }
                    // Restore the queue for scroll loading
                    window['_videoQueue_' + sec] = all.slice(10).map(function(v) { return v; });
                    if (status) {
                      var rem = all.length - 10;
                      if (rem > 0) {
                        status.style.display = '';
                        status.textContent = 'Scroll for more (' + rem + ' remaining)';
                      }
                    }
                    if (title) {
                      var label = title.textContent.replace(/\\s*\\(\\d+\\)/, '');
                      title.textContent = label + ' (' + all.length + ')';
                    }
                  }
                  continue;
                }

                // Filter — match against title (idx 2) and description (idx 4)
                var matches = [];
                for (var i = 0; i < all.length; i++) {
                  var t = (all[i][2] || '').toLowerCase();
                  var d = (all[i][4] || '').toLowerCase();
                  if (t.indexOf(q) !== -1 || d.indexOf(q) !== -1) {
                    matches.push(all[i]);
                  }
                }
                totalMatches += matches.length;
                grid.innerHTML = '';
                grid.setAttribute('data-filtered', '1');
                for (var i = 0; i < matches.length; i++) {
                  grid.appendChild(makeThumb(matches[i]));
                }
                // Update section title with match count
                if (title) {
                  var label = title.textContent.replace(/\\s*\\(\\d+.*\\)/, '');
                  title.textContent = label + ' (' + matches.length + ')';
                  title.style.display = matches.length === 0 ? 'none' : '';
                }
                if (status) { status.style.display = 'none'; }
                // Clear scroll queue during search
                window['_videoQueue_' + sec] = [];
              }
              if (q === '') {
                countEl.textContent = '';
              } else {
                countEl.textContent = totalMatches + ' found';
              }
            }

            input.addEventListener('input', doSearch);

            // Click-to-search on tag cloud
            var tagEls = document.querySelectorAll('.video-tag');
            for (var i = 0; i < tagEls.length; i++) {
              tagEls[i].addEventListener('click', function() {
                input.value = this.getAttribute('data-tag');
                doSearch();
                window.scrollTo({ top: input.getBoundingClientRect().top + window.scrollY - 20, behavior: 'smooth' });
              });
            }
          })();
          </script>
        HTML
      end
    end

    class Init < Template
      CSS_FILES = [ :navigation_css, :init_css ]
      COMPONENTS = {
        [0, 0] => TopNavigation,
        [0, 1] => component(Ticker, :movies),
        [0, 2] => InitComposite,
        [0, 3] => CheckThumbScript,
        [0, 4] => VideoSearchBar,
        [0, 5] => component(VideoClipsGrid, :video_clips),
        [0, 6] => component(VideoShortsGrid, :video_shorts),
        [0, 7] => component(VideoMoviesGrid, :video_movies),
        [0, 8] => PayPalDiv,
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
