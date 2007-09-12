dojo.provide("ywesee.widget.Show");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.declare(
  "ywesee.widget.Show",
	[dijit._Widget, dijit._Templated],
  {
    images: [],
    titles: [],

    startup: function(){
      if(this.images.length === 0) {
        var _this = this;
        dojo.xhrGet({
          url: this.dataUrl,
          handleAs: "json-comment-filtered",
          load: function(data, request) {
            _this.images = data.images; 
            _this.titles = data.titles; 
            _this.setup();
          }
        });
      } else {
        this.setup();
      }
    }

  }
);
