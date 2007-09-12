dojo.provide("ywesee.widget.Input");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.declare(
	"ywesee.widget.Input",
	//[dijit._Widget, dijit._Templated],
	[dijit._Widget],
	{
    //templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlInput.html"),

		//widget variables
		element_id_name: "",
		element_id_value: "",
		old_value: "",
		css_class: "",
		update_url: "",
		field_key: "",
		leText: null,
		leButtons: null,
		leInput: null,
		labels: false,
		label: "",

    //connection handlers
    divConn: null,
    labelConn: null,
    textConn: null,

		//attach points
		inputContainer: null,
		labelDiv: null,
		inputDiv: null,
		inputForm: null,

		startup: function() {
			this.prepareWidget();
		},

		prepareWidget: function() {
			this.inputDiv.className = this.css_class + " live-edit";
			this.addTextToDiv();
			this.addHiddenFieldsToForm();
		},
		
		keyDown: function(evt){
			if (evt.keyCode == 27) { // escape key
				this.cancelInput();
			}
		},

		cancelInput: function() {
			this.inputDiv.className = this.css_class + " live-edit";
			this.labelDiv.className = "label";
			this.inputForm.removeChild(this.leInput);
			this.inputContainer.removeChild(this.leButtons);
			this.addTextToDiv();
		},

		addTextToDiv: function() {
			if(this.labels) {
				this.labelDiv.innerHTML = this.label;
				this.inputDiv.style.marginLeft = "80px";
				this.labelConn = dojo.connect(this.labelDiv, "onclick", this, "toggleInput");
			}
			this.leText = document.createElement("span");
			this.leText.id = this.element_id_value + "-" + this.field_key; 
			this.leText.innerHTML = this.toHtml(this.old_value);
      this.divConn = dojo.connect(this.inputDiv, "onclick", this, "toggleInput");
			this.textConn = dojo.connect(this.leText, "onclick", this, "toggleInput");
			this.inputDiv.appendChild(this.leText);
		},

		addInputToForm: function() {
			//stub function to be filled by InputText or InputTextarea Widget
		},

		toggleInput: function() {
			dojo.disconnect(this.labelConn);
			dojo.disconnect(this.divConn);
			dojo.disconnect(this.textConn);
			this.inputDiv.className = this.css_class + " live-edit active";
			this.inputDiv.removeChild(this.leText);
			this.addInputToForm();
			this.addButtonsToContainer();
		},

		addButtonsToContainer: function() {
			this.leButtons = document.createElement("div");
			this.leButtons.className = 'edit-buttons';
			if(this.labels) {
				this.leButtons.style.marginLeft = '80px';
			}
			
			var submit = document.createElement("input");
			submit.type = "button";
			submit.value = "Save";
			dojo.connect(submit, "onclick", this, "saveChanges");
			this.leButtons.appendChild(submit);

			var cancel = document.createElement("input");
			cancel.type = "button";
			cancel.value = "Cancel";
			dojo.connect(cancel, "onclick", this, "cancelInput");
			this.leButtons.appendChild(cancel);

			this.inputContainer.appendChild(this.leButtons);
		},

		addHiddenFieldsToForm: function() {
			var eid = document.createElement("input");
			eid.type = "hidden";
			eid.name = this.element_id_name;
			eid.value = this.element_id_value;
			this.inputForm.appendChild(eid);
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
				strText = strText.replace( strTarget, strSubString );
				intIndexOfMatch = strText.indexOf( strTarget );
			}
			return( strText );
		},

		saveChanges: function(evt) {
			var form = this.inputForm;
			var _this = this;
			dojo.xhrPost({
				url: this.update_url,
				form: form,
				load: dojo.hitch(this, "saveSuccess"),
        handleAs: "json-comment-filtered"
			});	
			//this.old_value = _this.old_value; 
			evt.preventDefault();
		}, 

    saveSuccess: function(data, request) {
      this.old_value = data['updated_value'];
      this.leText.innerHTML = this.toHtml(data['updated_value']);
      this.cancelInput(); 
    }

	}
);
