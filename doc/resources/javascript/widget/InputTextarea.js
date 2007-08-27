dojo.provide("ywesee.widget.InputTextarea");

dojo.require("ywesee.widget.Input");
dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.widget.Editor2");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"ywesee.widget.InputTextarea",
	ywesee.widget.Input,
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlInput.html"),
    editor: null,

		fillInTemplate: function() {
			this.prepareWidget();
		},
		
		addInputToForm: function() {
			this.leInput = document.createElement("textarea");
			this.leInput.name = "update_value";
			this.leInput.value = this.old_value;
			this.leInput.className = this.css_class + " live-edit active";
			this.leInput.rows = "12";
			//dojo.event.connect(this.leInput, "onblur", this, "saveChanges");
			this.inputForm.appendChild(this.leInput);
			this.leInput.focus();
			this.editor = dojo.widget.createWidget("Editor2", 
				{ 
          shareToolbar: false,
          htmlEditing: true,
          useActiveX: false
				},
        this.leInput
      );
		},

		cancelInput: function() {
      this.inherited("cancelInput");
      this.editor.destroy();
      this.inputForm.removeChild(this.inputForm.lastChild);
    },

		saveChanges: function(evt) {
      if(this.editor._inHtmlMode) {
				this.editor.editNode.innerHTML = this.editor._htmlEditNode.value;
        this.editor.toggleHtmlEditing();
      }
      this.leInput.value = this.editor.getEditorContent();
      this.inherited("saveChanges", [evt]);
    }
  }
);



