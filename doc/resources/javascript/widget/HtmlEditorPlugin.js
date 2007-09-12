dojo.provide("ywesee.widget.HtmlEditorPlugin");

dojo.require("dijit.form.Button");

dojo.declare(
  "ywesee.widget.HtmlEditorPlugin", 
  dijit._editor._Plugin,
  {
    useDefaultCommand: false,
    command: "inserthtml",
    _inHtmlMode: false,
    _htmlEditNode: null,

    _initButton: function(){
      if(!this.button){
        var props = {
          label: "&lt;html&gt;",
          showLabel: true,
          iconClass: ""
        };
        this.button = new dijit.form.ToggleButton(props);
        dojo.connect(this.button, "onClick", this, "toggleHtmlEditing");
      }
    },
    toggleHtmlEditing: function(){
      var e = this.editor;
      if(!this._inHtmlMode){
        this._inHtmlMode = true;
        if(!this._htmlEditNode){
          this._htmlEditNode = document.createElement("textarea");
          dojo.place(this._htmlEditNode, e.editingArea, "after");
        }
        e.editingArea.style.display = "none";
        var node = this._htmlEditNode;
        node.value = e.getValue(true);
        node.style.display = "";
        node.style.width = "100%";
        node.style.height = "300px";
      }else{
        this._inHtmlMode = false;
        
        this._htmlEditNode.style.display = "none";
        this.pushValue();
        e.editingArea.style.display = "";
        e.editingArea.focus();
      }
    },
    pushValue: function() {
      this.editor.replaceValue(this._htmlEditNode.value);
    } 
  }
);
