/*
	Copyright (c) 2004-2005, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

dojo.provide("ywesee.widget.SlideShow");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.fx.html");
dojo.require("dojo.style");

ywesee.widget.SlideShow = function(){
	dojo.widget.HtmlWidget.call(this);

	this.templatePath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlSlideShow.html");
	// this.templateCssPath = dojo.uri.dojoUri("src/widget/templates/HtmlSlideShow.css");

	// over-ride some defaults
	this.isContainer = false;
	this.widgetType = "SlideShow";

	// useful properties
	this.images = [];	
	this.titles = [];
	this.imageHeight = "200px";
	this.imageIdx = 0;	
	this.delay = 4000;
	this.transitionInterval = 2000; 
	this.background = "container2"; 
	this.background_image = "img2"; 
	this.background_title = "title2"; 
	this.foreground = "container1"; 
	this.foreground_image = "img1"; 
	this.foreground_title = "title1"; 
	this.stopped = false;	
	this.fadeAnim = null; 
	this.critical = false;

	// our DOM nodes:
	this.imagesContainer = null;
	this.startStopButton = null;
	this.controlsContainer = null;
	this.container1 = null;
	this.container2 = null;
	this.img1 = null;
	this.img2 = null;
	this.title1 = null;
	this.title2 = null;

	this.fillInTemplate = function(){
		dojo.style.setOpacity(this.container1, 0.9999);
		dojo.style.setOpacity(this.container2, 0.9999);
		if(this.images.length>1){
			this.title2.innerHTML = this.titles[this.imageIdx];
			this.img2.style.height = this.imageHeight;
			this.img2.src = this.images[this.imageIdx++];
			this.endTransition();
		}else{
			this.img1.src = this.images[this.imageIdx++];
		}
	}

	this.togglePaused = function(){
		if(this.stopped){
			this.stopped = false;
			if(!this.critical)
			{
				this.backgroundImageLoaded(); // endTransition();
			}
			this.startStopImage.src= "/resources/images/global/pause.gif";
		}else{
			this.critical = true;
			this.stopped = true;
			this.startStopImage.src= "/resources/images/global/play.gif";
		}
	}

	this.backgroundImageLoaded = function(){

		if(this.stopped){ 
			this.critical = false;
			return; 
		}

		var _this = this; 
		var callback1 = function() { 
			_this.endTransition(); 
		};
		var callback2 = function() { 
			_this[_this.foreground].style.display = "none";
			_this[_this.background].style.display = "block";
			dojo.fx.html.fadeIn(_this[_this.background], _this.transitionInterval,
			callback1);
		};
		dojo.fx.html.fadeOut(this[this.foreground], this.transitionInterval, callback2);
	}
	
	this.endTransition = function(){
		var tmp = this.foreground;
		var tmp_image = this.foreground_image;
		var tmp_title = this.foreground_title;
		this.foreground = this.background;
		this.foreground_image = this.background_image;
		this.foreground_title = this.background_title;
		this.background = tmp;
		this.background_image = tmp_image;
		this.background_title = tmp_title;

		this.loadNextImage();
	}

	this.loadNextImage = function(){

		dojo.event.kwConnect({
			srcObj: this[this.background_image],
			srcFunc: "onload",
			adviceObj: this,
			adviceFunc: "backgroundImageLoaded",
			once: true, 
			delay: this.delay
		});

		dojo.style.setOpacity(this[this.background], 0);
		this[this.background_title].innerHTML = this.titles[this.imageIdx];
		this[this.background_image].src = this.images[this.imageIdx++];
		this[this.background_image].style.height = this.imageHeight;
		if(this.imageIdx>(this.images.length-1)){
			this.imageIdx = 0;
		}
	}
}
dojo.inherits(ywesee.widget.SlideShow, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:slideshow");
