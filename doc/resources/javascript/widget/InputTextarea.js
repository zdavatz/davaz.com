dojo.provide("ywesee.widget.InputTextarea");

dojo.require("ywesee.widget.EditWidget");
dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"dojo.widget.InputTextarea",
	dojo.widget.EditWidget,
	{
		widgetType: "InputTextarea",
		isContainer: false,

		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlInputTextarea.html"),

		fillInTemplate: function() {
			this.prepareWidget();
		},
		
		addInputToForm: function() {
			this.leInput = document.createElement("textarea");
			this.leInput.name = "update_value";
			this.leInput.value = this.old_value;
			this.leInput.className = this.css_class + " active";
			this.leInput.rows = "12";
			//dojo.event.connect(this.leInput, "onblur", this, "saveChanges");
			this.editWidgetForm.appendChild(this.leInput);
			this.leInput.focus();
		},
	}
);
