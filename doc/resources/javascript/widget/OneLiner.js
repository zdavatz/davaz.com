dojo.provide("ywesee.widget.OneLiner");

dojo.require("dojo.widget.*");
dojo.require("dojo.fx.*");

ywesee.widget.OneLiner = function() {

	dojo.widget.HtmlWidget.call(this);

	this.templatePath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlOneLiner.html");

	this.widgetType = "OneLiner";

	this.messages = [];
	this.colors = [];
	this.messageIdx = -1;
	this.nodeOut = "lineOne";
	this.nodeIn = "lineTwo";
	this.delay = 1200;

	this.nextMessage = function() {
		this.messageIdx++;
		if(this.messageIdx >= this.messages.length) {
			this.messageIdx = 0;	
		}
		this[this.nodeIn].innerHTML = this.messages[this.messageIdx];	
		this[this.nodeIn].style.color = 
			this.colors[this.messageIdx];
		var _this = this;
		var callback1 = function() { _this.endTransition(); };
		var callback2 = function() { 
			_this[_this.nodeOut].style.display = 'none';
			_this[_this.nodeIn].style.display = 'inline';
			dojo.fx.html.fadeIn(_this[_this.nodeIn], _this.delay,
			callback1);
		};
		dojo.fx.html.fadeOut(this[this.nodeOut], this.delay, callback2);
	}

	this.display = function() {
		var _this = this;
		var callback = function() { _this.nextMessage(); };
		dojo.lang.setTimeout(callback, this.delay);
	}

	this.fillInTemplate = function() {
		dojo.style.setOpacity(this.lineOne, 0.0);
		dojo.style.setOpacity(this.lineTwo, 0.0);
		this.nextMessage();
	}

	this.endTransition = function() {
		var tmp = this.nodeOut;
		this.nodeOut = this.nodeIn;
		this.nodeIn = tmp;

		this.display();
	}
}

dojo.inherits(ywesee.widget.OneLiner, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:oneliner");
