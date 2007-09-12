dojo.provide("ywesee.widget.Desk");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.declare(
  "ywesee.widget.Desk",
	[dijit._Widget, dijit._Templated],
  {

    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlDesk.html"),

    view: "Desk",

    images: [],	
    titles: [],
    dataUrl: "",
    serieId: "",
    deskContainer: null,
    deskContent: null,
    contentPane: null,

    startup: function(){
      var newDataUrl = this.dataUrl.replace(/ajax_rack/, 'ajax_desk');

      _this = this;

      console.debug("Desk.startup, getting: ", newDataUrl);
      dojo.xhrGet({
        url: newDataUrl,
        load: function(data, request) {
          _this.toggleInnerHTML(data);
        },
        error: function(data, request) { 
          console.debug("could not load Desk!", data, request); 
        },
        handleAs: "text"
      });
    },

    toggleInnerHTML: function(html) {
      this.deskContent.innerHTML = html;
      try {
        dojo.parser.parse(this.deskContent);
      } catch(e) {
        console.debug("could not parse desk content!"); 
      }
    }
  }
);
