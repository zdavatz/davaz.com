dojo.provide("ywesee.widget.InputTextarea");

dojo.require("ywesee.widget.Input");
dojo.require("dijit.Editor");
dojo.require("dijit._editor.plugins.LinkDialog");
dojo.require("dijit._editor.plugins.AlwaysShowToolbar");
dojo.require("ywesee.widget.HtmlEditorPlugin");

dojo.declare(
	"ywesee.widget.InputTextarea",
	[ywesee.widget.Input, dijit._Templated],
	{
    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlInput.html"),
    editor: null,
    htmlPlugin: null,

		addInputToForm: function() {
			this.leInput = document.createElement("input");
			this.leInput.name = "update_value";
      this.leInput.style.display = "none";
			this.inputForm.appendChild(this.leInput);
      var editor = document.createElement("textarea");
			editor.value = this.old_value;
      editor.innerHTML = this.old_value;
			editor.className = this.css_class + " live-edit active";
			editor.rows = "12";
			this.inputForm.appendChild(editor);
      var args = {
        extraPlugins: [ "dijit._editor.plugins.LinkDialog",
                        "dijit._editor.plugins.AlwaysShowToolbar"]
      };
      if(!dojo.isSafari) { args.height = ""; }
			this.editor = new dijit.Editor(args, editor);
      this.editor.addPlugin("ywesee.widget.HtmlEditorPlugin", 0);
      this.editor.startup();
      this.htmlPlugin = this.editor._plugins[0];
			this.editor.focus();
		},

		cancelInput: function() {
      this.inherited("cancelInput", arguments);
      this.editor.destroy();
      this.inputForm.removeChild(this.inputForm.lastChild);
    },

		saveChanges: function() {
      if(this.htmlPlugin._inHtmlMode) {
        this.htmlPlugin.toggleHtmlEditing();
      }
      this.leInput.value = this.editor.getValue();
      this.inherited("saveChanges", arguments);
    }
  }
);



