dojo.provide("ywesee.widget.OneLiner");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.declare(
  "ywesee.widget.OneLiner",
	[dijit._Widget, dijit._Templated],
  {

    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlOneLiner.html"),

    messages: [],
    colors: [],
    messageIdx: -1,
    nodeOut: "lineOne",
    nodeIn: "lineTwo",
    delay: 1200,

    nextMessage: function() {
      this.messageIdx++;
      if(this.messageIdx >= this.messages.length) {
        this.messageIdx = 0;	
      }

      this[this.nodeIn].innerHTML = this.messages[this.messageIdx];	
      this[this.nodeIn].style.color = this.colors[this.messageIdx];

      this.fadeOut();
    },

    fadeIn: function() {
      this[this.nodeOut].style.display = 'none';
      this[this.nodeIn].style.display = 'inline';
      var anim = dojo.fadeIn({ node:this[this.nodeIn], duration:this.delay });
      dojo.connect(anim, "onEnd", this, "endTransition");
      anim.play();
    },

    fadeOut: function() {
      var anim = dojo.fadeOut({ node:this[this.nodeOut], duration:this.delay }); 
      dojo.connect(anim, "onEnd", this, "fadeIn");
      anim.play();
    },

    display: function() {
      setTimeout(dojo.hitch(this, "nextMessage"), this.delay);
    },

    startup: function() {
      this.lineOne.style.opacity = 0.0;
      this.lineTwo.style.opacity = 0.0;
      this.nextMessage();
    },

    endTransition: function() {
      var tmp = this.nodeOut;
      this.nodeOut = this.nodeIn;
      this.nodeIn = tmp;

      this.display();
    }
  }
);
