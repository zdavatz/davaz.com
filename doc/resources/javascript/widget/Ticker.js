dojo.provide("ywesee.widget.Ticker");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.fx.html");
dojo.require("dojo.style");

ywesee.widget.Ticker = function() {
	dojo.widget.HtmlWidget.call(this);	

	this.templatePath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlTicker.html");
	
	this.isContainer = false;
	this.widgetType = "Ticker";

	this.images = []
	this.eventUrls = []
	this.windowWidth = 780;
	this.componentWidth =	140;
	this.divSize = this.componentWidth+"px";
	this.imageSize = this.componentWidth+"px";
	this.tickerSpeed = 4000;
	this.imagePosition = 0;

	this.tickerWindow = null;

	this.fillInTemplate = function() {
		container = dojo.byId('ticker-container');
		container.style.width = this.windowWidth+'px';
		var tickerWidth = (this.windowWidth+(4*this.componentWidth));
		this.tickerWindow.style.width = tickerWidth + 'px';	
		var imageNumber = Math.floor((tickerWidth / this.componentWidth));
		for (i = 0; i < imageNumber; i++) {
			if(i == (this.images.length-1)) {
				this.imagePosition = 0;
			} else {
				this.imagePosition += 1;	
			}
			var div = this.createImageDiv();
			this.tickerWindow.appendChild(div);
		}
		this.endTransition();
	}
	
	this.endTransition = function () {
		var _this = this;
		var callback = function() {
			var firstDiv = dojo.dom.firstElement(_this.tickerWindow, 'div');
			_this.tickerWindow.removeChild(firstDiv);
			_this.endTransition();
		};
		var wipeOutDiv = dojo.dom.firstElement(this.tickerWindow, 'div');
		this.wipe(wipeOutDiv, 5000, this.componentWidth, 0, callback);
		if(this.imagePosition == (this.images.length-1)) {
			this.imagePosition = 0;
		} else {
			this.imagePosition += 1;	
		}
		var div = _this.createImageDiv();
		this.tickerWindow.appendChild(div);
	}

	this.createImageDiv = function() {
		var div = document.createElement("div");
		div.style.width = this.divSize;
		div.style.height = this.divSize;
		div.style.clear = "none";
		var link = this.createImageLink();
		div.appendChild(link);
		return div;
	}

	this.createImageLink = function() {
		var img = document.createElement("img");
		img.src = this.images[this.imagePosition];
		img.alt = "movie";
		img.style.width = this.imageSize;
		img.style.height = this.imageSize;
		img.style.border = 'none';
		var link = document.createElement("a");
		link.href = this.eventUrls[this.imagePosition];
		link.appendChild(img);
		return link
	}

	this.wipe = function(node, duration, startWidth, endWidth, callback) {
		var anim = new dojo.animation.Animation([[startWidth], [endWidth]], duration||dojo.fx.duration, 0)
		var link = dojo.dom.firstElement(node, 'a');
		var img = dojo.dom.firstElement(link, 'img');
		var _this = this;
		dojo.event.connect(anim, "onAnimate", function(e) {
			node.style.width = e.x + "px";
			img.style.marginLeft = (e.x - _this.componentWidth) + "px";	
		});
		dojo.event.connect(anim, "onEnd", function() {
			if(callback) { callback(node, anim); }
		})
		anim.play();
		return anim;
	}
}

dojo.inherits(ywesee.widget.Ticker, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:ticker");
