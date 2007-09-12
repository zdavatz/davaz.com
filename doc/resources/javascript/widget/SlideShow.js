dojo.provide("ywesee.widget.SlideShow");

dojo.require("ywesee.widget.Show");

dojo.declare(
  "ywesee.widget.SlideShow",
	ywesee.widget.Show,
  {

    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlSlideShow.html"),

    // useful properties
    view: "SlideShow",
    imageHeight: "280px",
    imageIdx: 0,	
    delay: 3500,
    transitionInterval: 1500, 
    background: "container2", 
    background_image: "img2", 
    background_title: "title2", 
    foreground: "container1", 
    foreground_image: "img1", 
    foreground_title: "title1", 
    stopped: false,	
    fadeAnim: null, 
    critical: false,
    loadedCallback: 'backgroundImageLoaded',
    dataUrl: "",
    serieId: "",

    // our DOM nodes:
    imagesContainer: null,
    startStopButton: null,
    controlsContainer: null,
    container1: null,
    container2: null,
    img1: null,
    img2: null,
    title1: null,
    title2: null,

    was_patient: false,
    finished_loading: false,

    setup: function(){
      this.container1.style.opacity = 0.9999;
      this.container2.style.opacity = 0.9999;
      this.title2.innerHTML = this.titles[this.imageIdx];
      this.img2.src = this.images[this.imageIdx];
      if(this.img2.width > 800) {
        this.img2.style.height = 'auto';
        this.img2.style.width = '600px';
      } else {
        this.img2.style.height = this.imageHeight;
        this.img2.style.width = 'auto';
      }
      this.imageIdx++;
      this.endTransition();
    },

    togglePaused: function(){
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
    },

    backgroundImageLoaded: function(){

      this.finished_loading = true;
      if(!this.was_patient) { return; }

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
        try {
          dojo.fadeIn({node:_this[_this.background], 
                       duration:_this.transitionInterval, 
                       onEnd:callback1}).play();
        } catch(e) {
          // apparently, IE6 can't do fades on spans
          callback1();
        }
      };
      try {
        dojo.fadeOut({node:this[this.foreground], 
                      duration:this.transitionInterval, 
                      onEnd:callback2}).play();
      } catch(e) {
        // apparently, IE6 can't do fades on spans
        callback2();
      }
    },
    
    endTransition: function(){
      var tmp = this.foreground;
      var tmp_image = this.foreground_image;
      var tmp_title = this.foreground_title;
      this.foreground = this.background;
      this.foreground_image = this.background_image;
      this.foreground_title = this.background_title;
      this.background = tmp;
      this.background_image = tmp_image;
      this.background_title = tmp_title;

      if(this.images.length > 1) { this.loadNextImage(); }
    },

    showNextImage: function() {
      this.was_patient = true; 
      if(this.finished_loading) {
        this.backgroundImageLoaded();
      }
    },

    loadNextImage: function(){

      this.was_patient = false;
      this.finished_loading = false;
      setTimeout(dojo.hitch(this, "showNextImage"), this.delay);
      dojo.connect(this[this.background_image], "onload", this, "backgroundImageLoaded");
        //once: true, 
        //delay: this.delay
      //});

      this[this.background].style.opacity = 0;
      this[this.background_title].innerHTML = this.titles[this.imageIdx];
      this[this.background_image].src = this.images[this.imageIdx++];
      if(this[this.background_image].width > 800) {
        this[this.background_image].style.width = '600px';
        this[this.background_image].style.height = 'auto';
      } else {
        this[this.background_image].style.width = 'auto';
        this[this.background_image].style.height = this.imageHeight;
      }
      if(this.imageIdx>(this.images.length-1)){
        this.imageIdx = 0;
      }
    }
  }
);
