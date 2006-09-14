dojo.provide("ywesee.widget.Input");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"ywesee.widget.Input",
	dojo.widget.HtmlWidget, 
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlInput.html"),

		//widget variables
		artobject_id: "",
		old_value: "",
		css_class: "",
		update_url: "",
		field_key: "",
		leText: null,
		leButtons: null,
		leInput: null,

		//attach points
		inputContainer: null,
		inputDiv: null,
		inputForm: null,

		fillInTemplate: function() {
			this.prepareWidget();
		},

		prepareWidget: function() {
			this.inputDiv.className = this.css_class;
			dojo.event.connect(this.inputDiv, "onclick", this, "toggleInput");
			this.addTextToDiv();
			this.addHiddenFieldsToForm();
		},
		
		keyDown: function(evt){
			if (evt.keyCode == 27) { // escape key
				this.cancelInput();
			}
		},

		cancelInput: function() {
			this.inputDiv.className = this.css_class;
			this.inputForm.removeChild(this.leInput);
			this.inputContainer.removeChild(this.leButtons);
			this.addTextToDiv();
		},

		addTextToDiv: function() {
			this.leText = document.createElement("span");
			this.leText.innerHTML = this.toHtml(this.old_value);
			var _this = this;
			dojo.event.connect(this.leText, "onclick", this, "toggleInput");
			this.inputDiv.appendChild(this.leText);
		},

		addInputToForm: function() {
			dojo.debug("not yet");
			//stub function to be filled by InputText or InputTextarea Widget
		},

		toggleInput: function() {
			this.inputDiv.className = this.css_class + " active";
			this.inputDiv.removeChild(this.leText);
			this.addInputToForm();
			this.addButtonsToContainer();
		},

		addButtonsToContainer: function() {
			this.leButtons = document.createElement("div");
			this.leButtons.className = 'edit-buttons';
			
			var submit = document.createElement("input");
			submit.type = "button";
			submit.value = "Save";
			dojo.event.connect(submit, "onclick", this, "saveChanges");
			this.leButtons.appendChild(submit);

			var cancel = document.createElement("input");
			cancel.type = "button";
			cancel.value = "Cancel";
			dojo.event.connect(cancel, "onclick", this, "cancelInput");
			this.leButtons.appendChild(cancel);

			this.inputContainer.appendChild(this.leButtons);
		},

		addHiddenFieldsToForm: function() {
			var aid = document.createElement("input");
			aid.type = "hidden";
			aid.name = "artobject_id";
			aid.value = this.artobject_id;
			this.inputForm.appendChild(aid);
			var fkey = document.createElement("input");
			fkey.type = "hidden";
			fkey.name = "field_key";
			fkey.value = this.field_key;
			this.inputForm.appendChild(fkey);
			var oldvalue = document.createElement("input");
			oldvalue.type = "hidden";
			oldvalue.name = "old_value";
			oldvalue.value = this.old_value;
			this.inputForm.appendChild(oldvalue);
		},

		toHtml: function(strText) {
			var strTarget = "\n"; 
			var strSubString = "<br />";
			
			var intIndexOfMatch = strText.indexOf( strTarget );

			while (intIndexOfMatch != -1){
				strText = strText.replace( strTarget, strSubString )
				intIndexOfMatch = strText.indexOf( strTarget );
			}
			return( strText );
		},

		saveChanges: function(evt) {
			var form = this.inputForm;
			var _this = this;
			dojo.io.bind({
				url: this.update_url,
				formNode: form,
				load: function(type, data, event) {
					_this.inputForm.removeChild(_this.leInput);
					_this.inputContainer.removeChild(_this.leButtons);
					_this.old_value = data['updated_value'];
					_this.leText.innerHTML = _this.toHtml(data['updated_value']);
					_this.inputDiv.appendChild(_this.leText);
					_this.inputDiv.className = _this.css_class;
				},
				mimetype: "text/json"
			});	
			this.old_value = _this.old_value; 
			evt.preventDefault();
		},

	}
);
