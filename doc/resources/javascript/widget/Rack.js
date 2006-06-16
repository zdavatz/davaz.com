dojo.provide("ywesee.widget.Rack");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.fx.html");
dojo.require("dojo.style");

ywesee.widget.Rack = function(){
	dojo.widget.HtmlWidget.call(this);

	this.templatePath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlRack.html");

	this.toggleBusy = false;
	this.isContainer = false;
	this.widgetType = "Rack";

	this.images = [];	
	this.titles = [];
	this.dataUrl = "";

	this.imageContainer = null;
	this.thumbContainer = null;
	this.imageTitleContainer = null;
	this.imageTitle = null;
	this.displayImage = null;

	this.fillInTemplate = function(){
		var imageCount = this.images.length;		
		var columnsCount = Math.floor(Math.sqrt(imageCount));
		var rowsCount = Math.ceil(imageCount/columnsCount);
		var cWidth = Math.floor((349/columnsCount)-8);
		var rHeight = Math.floor((349/rowsCount)-8);

		this.fillInDisplay();
		this.fillInThumbContainer(imageCount, cWidth, rHeight);
	}

	this.fillInDisplay = function() {
		this.displayImage.src = this.images[0];
		this.imageTitle.innerHTML = this.titles[0];
	}

	this.toggleDisplay = function(img) {
		if(this.toggleBusy) return;
		if(this.displayImage.src == img.src) return;
		this.toggleBusy = true;
		_this = this;
		var callback2 = function() { _this.toggleBusy = false; }
		var callback1 = function() {
			_this.displayImage.src = img.src;
			_this.displayImage.alt = img.alt;
			_this.imageTitle.innerHTML = img.alt;
			dojo.fx.fadeIn(_this.displayImage, 200, callback2);
		}
		dojo.fx.fadeOut(this.displayImage, 200, callback1);
	}

	this.fillInThumbContainer = function(imageCount, cWidth, rHeight) {
		for(idx = 0; idx < imageCount; idx++) {
			var div = document.createElement("div");
			div.style.width = cWidth + "px";
			div.style.height = rHeight + "px";
			div.style.overflow = 'hidden';
			div.style.cssFloat = 'left';
			var img = document.createElement("img")
			img.src = this.images[idx];
			img.alt = this.titles[idx];
			_this = this;
			img.onmouseover = function() {
				_this.toggleDisplay(this); 
			};
			div.appendChild(img);
			this.thumbContainer.appendChild(div);
		}
	}

	this.refill = function(data) {
		var thumbs = this.thumbContainer;
		var imageCount = this.images.length;
		for(idx = 0; idx < imageCount; idx++) {
			thumbs.removeChild(thumbs.childNodes[0]);
		}
		for(name in data) {
			this[name] = data[name];
		}
		//this.images = images;
		//this.titles = titles;
		this.fillInTemplate();
	}
}

dojo.inherits(ywesee.widget.Rack, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:rack");
