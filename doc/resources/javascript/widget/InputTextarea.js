dojo.provide("ywesee.widget.InputTextarea");

dojo.require("ywesee.widget.Input");
dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"ywesee.widget.InputTextarea",
	ywesee.widget.Input,
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlInput.html"),

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
		},
	}
);
