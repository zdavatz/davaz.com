dojo.provide("ywesee.widget.Tooltip");

dojo.require("dijit.Tooltip");
dojo.require("dijit.layout.ContentPane");

dojo.declare(
  "ywesee.widget.Tooltip",    
  [dijit.Tooltip],
  {
    href: null,
    contentPane: null,

    open: function(){
      if(this.isShowingNow) { return; }

      if(this.href && (!this.contentPane)) {
        this.domNode = document.createElement("div");
        this.contentPane = new dijit.layout.ContentPane({href:this.href}, this.domNode);
        dojo.connect(this.contentPane, 'onLoad', this, 'onLoad');
        this.contentPane.startup();
      }

      this.inherited("open", arguments);
    },

    onLoad: function(){
      if(this.isShowingNow){
        this.close();
        this.open();
      }
    }
  }
);
