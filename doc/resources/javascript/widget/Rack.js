dojo.provide("ywesee.widget.Rack");

dojo.require("ywesee.widget.Show");

dojo.declare(
  "ywesee.widget.Rack",
	ywesee.widget.Show,
  {

    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlRack.html"),

    view: "Rack",
    toggleBusy: false,

    artObjectIds: [],	
    artGroupIds: [],	
    dataUrl: "",
    serieId: "",

    imageContainer: null,
    thumbContainer: null,
    imageTitleContainer: null,
    imageTitle: null,
    displayImage: null,

    setup: function(){
      var imageCount = this.images.length;		
      var columnsCount = Math.floor(Math.sqrt(imageCount));
      var rowsCount = Math.ceil(imageCount/columnsCount);
      var cWidth = Math.floor((349/columnsCount)-8);
      var rHeight = Math.floor((349/rowsCount)-8);

      this.fillInDisplay();
      this.fillInThumbContainer(imageCount, cWidth, rHeight);
    },

    fillInDisplay: function() {
      this.displayImage.src = this.images[0];
      this.imageTitle.innerHTML = this.titles[0];
    },

    toggleDisplay: function(img) {
      if(this.toggleBusy) return;
      if(this.displayImage.src == img.src) return;
      /* Code with fade
      this.toggleBusy = true;
      _this = this;
      var callback2 = function() { _this.toggleBusy = false; }
      var callback1 = function() {
        _this.displayImage.src = img.src;
        _this.displayImage.alt = img.alt;
        _this.imageTitle.innerHTML = img.alt;
        dojo.lfx.fadeIn(_this.displayImage, 200, null, callback2).play();
      }
      dojo.lfx.fadeOut(this.displayImage, 200, null, callback1).play();
      */
      /* No fading desired */
      this.displayImage.src = img.src;
      this.displayImage.alt = img.alt;
      this.imageTitle.innerHTML = img.alt;
    },

    fillInThumbContainer: function(imageCount, cWidth, rHeight) {
      for(idx = 0; idx < imageCount; idx++) {
        var div = document.createElement("div");
        div.style.width = cWidth + "px";
        div.style.height = rHeight + "px";
        //div.style.overflow = 'hidden';
        //div.style.cssFloat = 'left';
        var img = document.createElement("img")
        img.name = this.artObjectIds[idx];
        img.src = this.images[idx];
        img.style.width = '180px';
        img.alt = this.titles[idx];
        var _this = this;
        img.onmouseover = function() {
          _this.toggleDisplay(this); 
        };
        div.appendChild(img);
        this.thumbContainer.appendChild(div);
      }
    },

    refill: function(data) {
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
);
