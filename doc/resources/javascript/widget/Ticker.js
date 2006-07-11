dojo.provide("ywesee.widget.Ticker");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.html");
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
	this.componentWidth =	180;
	this.componentHeight = 180;
	this.tickerSpeed = 4000;
	this.imagePosition = 0;
	this.pause = false;

	this.tickerWindow = null;

	this.fillInTemplate = function() {
		this.divWidth = this.componentWidth+2+"px";
		this.divHeight = this.componentHeight+2+"px";
		this.imageWidth = this.componentWidth+"px";
		this.imageHeight = this.componentHeight+"px";
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
			var div = document.createElement("div");
			this.assembleImageDiv(div);
			this.updateImageDiv(div);
			this.tickerWindow.appendChild(div);
		}
		if(!this.pause) {
			this.endTransition();
		}
	}

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
	
	this.endTransition = function () {
		var _this = this;
		var div = '';
		var callback = function() {
			var firstDiv = dojo.dom.firstElement(_this.tickerWindow, 'div');
			div = _this.tickerWindow.removeChild(firstDiv);
			_this.updateImageDiv(div);
			_this.tickerWindow.appendChild(div);
			if(_this.pause) {
				return;
			} else {
				_this.endTransition();
			}
		};
		var wipeOutDiv = dojo.dom.firstElement(this.tickerWindow, 'div');
		this.wipe(wipeOutDiv, 5000, this.componentWidth, 0, callback).play();
		if(this.imagePosition == (this.images.length-1)) {
			this.imagePosition = 0;
		} else {
			this.imagePosition += 1;	
		}
	}

	this.updateImageDiv = function(div) {
		var link = dojo.dom.firstElement(div, 'a');
		var img = dojo.dom.firstElement(link, 'img');
		div.style.width = this.divWidth;
		div.style.height = this.divHeight;
		div.style.clear = "none";
		img.src = this.images[this.imagePosition];
		img.style.marginLeft = '0px'
		link.href = this.eventUrls[this.imagePosition];
	}

	this.assembleImageDiv = function(div) {
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
	}

	this.wipe = function(node, duration, startWidth, endWidth, callback) {
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

dojo.inherits(ywesee.widget.Ticker, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:ticker");
