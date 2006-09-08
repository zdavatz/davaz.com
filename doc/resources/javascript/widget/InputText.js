dojo.provide("ywesee.widget.InputText");

dojo.require("ywesee.widget.EditWidget");
dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"dojo.widget.InputText",
	dojo.widget.EditWidget,
	{
		widgetType: "InputText",
		isContainer: false,

		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlInputText.html"),

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
			this.editWidgetForm.appendChild(this.leInput);
			this.leInput.focus();
		},
	}
);
