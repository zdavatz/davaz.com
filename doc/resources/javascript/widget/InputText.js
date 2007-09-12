dojo.provide("ywesee.widget.InputText");

dojo.require("ywesee.widget.Input");

dojo.declare(
	"ywesee.widget.InputText",
	[ywesee.widget.Input, dijit._Templated],
	{
    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlInput.html"),
  /*
		startup: function() {
			this.prepareWidget();
		},
    */
		
		addInputToForm: function() {
			this.leInput = document.createElement("input");
			this.leInput.type = "text";
			this.leInput.name = "update_value";
			this.leInput.value = this.old_value;
			this.leInput.className = this.css_class + " live-edit active";
			this.leInput.id = this.element_id_value + "-" + this.field_key; 
			dojo.connect(this.leInput, "onkeydown", this, "keyDown");
			this.inputForm.appendChild(this.leInput);
			this.leInput.focus();
		}
	}
);
