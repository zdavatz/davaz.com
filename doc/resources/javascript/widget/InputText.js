dojo.provide("ywesee.widget.InputText");

dojo.require("ywesee.widget.Input");
dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"ywesee.widget.InputText",
	ywesee.widget.Input,
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlInput.html"),

		fillInTemplate: function() {
			this.prepareWidget();
		},
		
		addInputToForm: function() {
			this.leInput = document.createElement("input");
			this.leInput.type = "text";
			this.leInput.name = "update_value";
			this.leInput.value = this.old_value;
			this.leInput.className = this.css_class + " active";
			dojo.event.connect(this.leInput, "onkeydown", this, "keyDown");
			this.inputForm.appendChild(this.leInput);
			this.leInput.focus();
		},
	}
);
