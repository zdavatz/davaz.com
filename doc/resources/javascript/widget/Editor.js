dojo.provide("ywesee.widget.Editor");

dojo.require("dijit.Editor");
dojo.require("dijit._Templated");
dojo.require("dijit._editor.plugins.LinkDialog");
dojo.require("dijit._editor.plugins.AlwaysShowToolbar");
dojo.require("ywesee.widget.HtmlEditorPlugin");

dojo.declare(
  "ywesee.widget.Editor",
	[dijit._Widget, dijit._Templated],
  {
    templatePath: dojo.moduleUrl("ywesee.widget", "templates/Editor.html"),
    container: null,
    editorNode: null,
    editor: null,
    htmlPlugin: null,
    leInput: null,
    value: "",
    name: "text",

    startup: function(){
      this.leInput.name = this.name;
      this.leInput.innerHTML = this.value;
      this.editorNode.focus();
      this.editor = new dijit.Editor( { 
          extraPlugins: [ "dijit._editor.plugins.LinkDialog", 
                          "dijit._editor.plugins.AlwaysShowToolbar"],
          height: ""
        },
        this.editorNode);
      this.editor.addPlugin("ywesee.widget.HtmlEditorPlugin", 0);
      this.editor.startup();
      this.editor.setValue(this.value);
      this.htmlPlugin = this.editor._plugins[0];
    },
    onSubmit: function() {
      if(this.htmlPlugin._inHtmlMode) {
        this.htmlPlugin.toggleHtmlEditing();
      }
      this.leInput.innerHTML = this.editor.getValue(true);
    }

  }
);
