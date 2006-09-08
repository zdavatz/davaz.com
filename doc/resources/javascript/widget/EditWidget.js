dojo.provide("ywesee.widget.EditWidget");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"dojo.widget.EditWidget",
	dojo.widget.HtmlWidget, 
	{
		widgetType: "EditWidget",
		isContainer: false,

		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlEditWidget.html"),

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
		editWidgetContainer: null,
		editWidgetDiv: null,
		editWidgetForm: null,

		fillInTemplate: function() {
			this.prepareWidget();
		},

		prepareWidget: function() {
			this.editWidgetDiv.className = this.css_class;
			dojo.event.connect(this.editWidgetDiv, "onclick", this, "toggleInput");
			this.addTextToDiv();
			//dojo.event.connect(this.editWidgetForm, "onblur", this, "saveChanges");
			this.addHiddenFieldsToForm();
		},
		
		keyDown: function(evt){
			if (evt.keyCode == 27) { // escape key
				this.cancelInput();
			}
		},

		cancelInput: function() {
			this.editWidgetDiv.className = this.css_class;
			this.editWidgetForm.removeChild(this.leInput);
			this.editWidgetContainer.removeChild(this.leButtons);
			this.addTextToDiv();
		},

		addTextToDiv: function() {
			this.leText = document.createElement("span");
			this.leText.innerHTML = this.toHtml(this.old_value);
			var _this = this;
			dojo.event.connect(this.leText, "onclick", this, "toggleInput");
			this.editWidgetDiv.appendChild(this.leText);
		},

		addInputToForm: function() {
			//stub function to be filled by InputText or InputTextarea Widget
		},

		toggleInput: function() {
			this.editWidgetDiv.className = this.css_class + " active";
			this.editWidgetDiv.removeChild(this.leText);
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

			this.editWidgetContainer.appendChild(this.leButtons);
		},

		addHiddenFieldsToForm: function() {
			var aid = document.createElement("input");
			aid.type = "hidden";
			aid.name = "artobject_id";
			aid.value = this.artobject_id;
			this.editWidgetForm.appendChild(aid);
			var fkey = document.createElement("input");
			fkey.type = "hidden";
			fkey.name = "field_key";
			fkey.value = this.field_key;
			this.editWidgetForm.appendChild(fkey);
			var oldvalue = document.createElement("input");
			oldvalue.type = "hidden";
			oldvalue.name = "old_value";
			oldvalue.value = this.old_value;
			this.editWidgetForm.appendChild(oldvalue);
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
			var form = this.editWidgetForm;
			var _this = this;
			dojo.io.bind({
				url: this.update_url,
				formNode: form,
				load: function(type, data, event) {
					_this.editWidgetForm.removeChild(_this.leInput);
					_this.editWidgetContainer.removeChild(_this.leButtons);
					_this.old_value = data['updated_value'];
					_this.leText.innerHTML = _this.toHtml(data['updated_value']);
					_this.editWidgetDiv.appendChild(_this.leText);
					_this.editWidgetDiv.className = _this.css_class;
				},
				mimetype: "text/json"
			});	
			this.old_value = _this.old_value; 
			evt.preventDefault();
		},

	}
);
