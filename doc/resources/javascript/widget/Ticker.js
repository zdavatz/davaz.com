dojo.provide("ywesee.widget.Ticker");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");
dojo.require("dojo.validate");

dojo.widget.defineWidget(
	"ywesee.widget.Ticker",
	dojo.widget.HtmlWidget,
  {

    templatePath:
      dojo.uri.dojoUri("../javascript/widget/templates/HtmlTicker.html"),
    
    isContainer: false,
    widgetType: "Ticker",

    images: [],
    eventUrls: [],
    windowWidth: 780,
    componentWidth:	180,
    componentHeight: 180,
    tickerSpeed: 4000,
    imagePosition: 0,
    stopped: false,
    critical: false,

    tickerWindow: null,

    fillInTemplate: function() {
      this.divWidth = this.componentWidth+2+"px";
      this.divHeight = this.componentHeight+2+"px";
      this.imageWidth = this.componentWidth+"px";
      this.imageHeight = this.componentHeight+"px";
      var container = dojo.byId("ticker-container");
      container.style.width = this.windowWidth+'px';
      var tickerWidth = (this.windowWidth+(4*this.componentWidth));
      this.tickerWindow.style.width = tickerWidth + 'px';	
      var imageNumber = Math.floor((tickerWidth / this.componentWidth));
      for (i = 0; i < imageNumber; i++) {
        if(i == (this.images.length-1)) {
          this.imagePosition = 0;
        }
        var div = document.createElement("div");
        this.assembleImageDiv(div);
        this.updateImageDiv(div);
        this.tickerWindow.appendChild(div);
        this.imagePosition += 1;	
      }
      if(!this.stopped) {
        this.endTransition();
      }
    },

  /*
    this.countChildren = function(parentNode) {
      count = 0;
      var node = parentNode.firstChild;	
      while(node && node.Type != dojo.dom.ELEMENT_NODE){
        node = node.nextSibling;
        count += 1;
      }
      return count;
    }
  */
    
    endTransition: function () {
      var _this = this;
      var div = '';
      var callback = function() {
        var firstDiv = dojo.dom.firstElement(_this.tickerWindow, 'div');
        div = _this.tickerWindow.removeChild(firstDiv);
        _this.updateImageDiv(div);
        _this.tickerWindow.appendChild(div);
        if(_this.imagePosition == (_this.images.length-1)) {
          _this.imagePosition = 0;
        } else {
          _this.imagePosition += 1;	
        }
        if(_this.stopped) {
          _this.critical = false;
          return;
        } else {
          _this.endTransition();
        }
      };
      var wipeOutDiv = dojo.dom.firstElement(this.tickerWindow, 'div');
      this.wipe(wipeOutDiv, 5000, this.componentWidth, 0, callback).play();
    },

    togglePaused: function() {
      if(this.stopped){
        this.stopped = false;
        if(!this.critical) {
          this.endTransition();
        }
      } else {
        this.critical = true;
        this.stopped = true;
      }
    },

    updateImageDiv: function(div) {
      var link = dojo.dom.firstElement(div, 'a');
      var img = dojo.dom.firstElement(link, 'img');
      div.style.width = this.divWidth;
      div.style.height = this.divHeight;
      div.style.clear = "none";
      img.src = this.images[this.imagePosition];
      img.style.marginLeft = '0px'
      link.href = this.eventUrls[this.imagePosition];
    },

    assembleImageDiv: function(div) {
      var img = document.createElement("img");
      img.src = this.images[this.imagePosition];
      img.alt = "movie";
      img.style.width = this.imageWidth;
      img.style.height = this.imageHeight;
      img.style.border = 'none';
      var link = document.createElement("a");
      link.href = this.eventUrls[this.imagePosition];
      link.appendChild(img);
      div.appendChild(link);
    },

    wipe: function(node, duration, startWidth, endWidth, callback) {
      var _this = this;
      var link = dojo.dom.firstElement(node, 'a');
      var img = dojo.dom.firstElement(link, 'img');
      var anim = new dojo.lfx.Animation({
        onAnimate: function(e) {
          node.style.width = e + "px";
          img.style.marginLeft = (e - _this.componentWidth) + "px";	
        },
        onEnd: function() {
          if(callback) { callback(node, anim); }
        } }, duration, [startWidth, endWidth]);
      return anim;
    }

  }

);
