dojo.provide("ywesee.widget.Desk");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.html");
dojo.require("dojo.style");

ywesee.widget.Desk = function(){
	dojo.widget.HtmlWidget.call(this);

	this.templatePath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlDesk.html");

	this.isContainer = false;
	this.widgetType = "Desk";

	this.images = [];	
	this.titles = [];
	this.dataUrl = "";
	this.serieId = "";
	this.deskContainer = null;
	this.deskContent = null;

	this.fillInTemplate = function(){
		var newDataUrl = this.dataUrl.replace(/ajax_rack/, 'ajax_desk');
		
		_this = this;

		dojo.io.bind({
			url: newDataUrl,
			load: function(type, data, event) {
				_this.deskContent.innerHTML = data;
			},
			mimetype: "text/html"
		});
	}

	this.toggleInnerHTML = function(html) {
		this.deskContent.innerHTML = html;		
	}
}

dojo.inherits(ywesee.widget.Desk, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:desk");
