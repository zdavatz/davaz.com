dojo.provide("ywesee.widget.OneLiner");

dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");

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
		this[this.nodeIn].style.color = this.colors[this.messageIdx];
		var _this = this;
		var callback1 = function() { _this.endTransition(); };
		var callback2 = function() { 
			_this[_this.nodeOut].style.display = 'none';
			_this[_this.nodeIn].style.display = 'inline';
      try {
        dojo.lfx.html.fadeIn(_this[_this.nodeIn], _this.delay, null, callback1).play();
      } catch(e) { 
        // apparently, IE6 can't do fades on spans
        callback1();
      }
		};
    try {
      dojo.lfx.html.fadeOut(this[this.nodeOut], this.delay, null, callback2).play();
    } catch(e) { 
      // apparently, IE6 can't do fades on spans
      callback2();
    }
	}

	this.display = function() {
		var _this = this;
		var callback = function() { _this.nextMessage(); };
		dojo.lang.setTimeout(callback, this.delay);
	}

	this.fillInTemplate = function() {
    if(dojo.render.html.ie) {
      this.lineOne.style.filter = "alpha(opacity='0')" ;
      this.lineTwo.style.filter = "alpha(opacity='0')" ;
    }
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
