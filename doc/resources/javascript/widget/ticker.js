define([
  'dojo/_base/declare'
, 'dojo/_base/fx'
, 'dojo/query'
, 'dojo/dom'
, 'dojo/dom-geometry'
, 'dojo/dom-style'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
], function(declare, fx, query, dom, geo, styl, _wb, _tm) {
  return declare('ywesee.widget.ticker', [_wb, _tm], {
    base_class:  'ticker-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/ticker.html')
  , images:          []
  , eventUrls:       []
  , windowWidth:     780
  , componentWidth:  180
  , componentHeight: 180
  , imagePosition:   0
  , stopped:         false
  , critical:        false
    // callbacks
  , constructor: function(params, srcNodeRef) {
      if (location.href.match(/\/personal\/home\/?$/i)) {
        // full width
        // NOTE:
        //  firefox and chromium might return different screen size
        this.windowWidth = screen.width - 16;
      }
    }
  , postCreate: function() {
      this.divWidth    = this.componentWidth  + 2 + 'px';
      this.divHeight   = this.componentHeight + 1 + 'px';
      this.imageWidth  = this.componentWidth  + 'px';
      this.imageHeight = this.componentHeight + 'px';
      var container = dom.byId('ticker_container');
      container.style.width = this.windowWidth + 'px';
      var tickerWidth = (this.windowWidth + (4 * this.componentWidth));
      this.domNode.style.width = tickerWidth + 'px';
      this.width = tickerWidth + 'px';
      var imageNumber = Math.floor((tickerWidth / this.componentWidth));
      for (i = 0; i < imageNumber; i++) {
        if (i == (this.images.length - 1)) {
          this.imagePosition = 0;
        }
        var div = document.createElement('div');
        this.assembleImageDiv(div);
        this.updateImageDiv(div);
        this.domNode.appendChild(div);
        this.imagePosition += 1;
      }
      if (!this.stopped) {
        this.endTransition();
      }
    }
  , endTransition: function () {
      var _this = this;
      var div = '';
      var callback = function() {
        var firstDiv = query('div', _this.domNode)[0];
        div = _this.domNode.removeChild(firstDiv);
        _this.updateImageDiv(div);
        _this.domNode.appendChild(div);
        if (_this.imagePosition == (_this.images.length - 1)) {
          _this.imagePosition = 0;
        } else {
          _this.imagePosition += 1;
        }
        if (_this.stopped) {
          _this.critical = false;
          return;
        } else {
          _this.endTransition();
        }
      };
      var wipeOutDiv = query('div', this.domNode)[0];
      this.wipe(wipeOutDiv, 3620, this.componentWidth, 0, callback).play();
    }
  , updateImageDiv: function(div) {
      var link = query('a', div)[0]
        , img  = query('img', link)[0]
        ;
      div.style.width  = this.divWidth;
      div.style.height = this.divHeight;
      div.style.clear  = 'none';
      img.src              = this.images[this.imagePosition];
      img.style.marginLeft = '0px';
      link.href = this.eventUrls[this.imagePosition];
    }
  , assembleImageDiv: function(div) {
      var link = document.createElement('a')
        , img  = document.createElement('img')
        ;
      img.src = this.images[this.imagePosition];
      img.alt = 'movie';
      img.style.width  = this.imageWidth;
      img.style.height = this.imageHeight;
      img.style.border = 'none';
      link.href = this.eventUrls[this.imagePosition];
      link.appendChild(img);
      div.appendChild(link);
    }
  , wipe: function(node, duration, startWidth, endWidth, callback) {
      var _this = this;
      var link = query('a', node)[0]
        , img  = query('img', link)[0]
        ;
      return fx.animateProperty({
        node:      node
      , onAnimate: function() {
          var pos = geo.position(node);
          node.style.width = (pos.w - 1) + 'px';
        }
      , onEnd: function() {
          if (callback) { callback(); }
        }
      , duration: duration
      });
    }
  , TogglePaused: function() {
      if (this.stopped) {
        this.stopped = false;
        if (!this.critical) {
          this.endTransition();
        }
      } else {
        this.critical = true;
        this.stopped  = true;
      }
    }
  });
});
