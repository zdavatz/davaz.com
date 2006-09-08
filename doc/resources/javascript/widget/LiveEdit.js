dojo.provide("ywesee.widget.LiveEdit");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

ywesee.widget.LiveEdit = function() {

	dojo.widget.HtmlWidget.call(this);	

	this.templatePath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlLiveEdit.html");
	this.templateCssPath = 
		dojo.uri.dojoUri("../javascript/widget/templates/HtmlLiveEdit.css");

	this.isContainer = true;
	this.widgetType = "LiveEdit";

	this.artobject_id = "";
	this.value = "";
	this.css_class = "";
	this.update_url = "";
	this.field_key = "";
	this.className = "";
	this.liveEditContainer = null;
	this.liveEditDiv = null;
	this.liveEditForm = null;
	this.leText = null;
	this.leInput = null;


	this.fillInTemplate = function() {
		if(this.value == '') {
			return 0;
		} else {
			this.className = this.liveEditDiv.className;
			this.liveEditContainer.className = this.css_class;
			dojo.event.connect(this.liveEditContainer, "onclick", this, "toggleInput");
			this.addTextToDiv();
			dojo.event.connect(this.liveEditForm, "onblur", this, "saveChanges");
			this.addHiddenFieldsToForm();
		}
	}

	this.keyDown = function(evt){
		if (evt.keyCode == 27) { // escape key
			this.liveEditDiv.className = this.className;
			this.liveEditForm.removeChild(this.leInput);
			this.addTextToDiv();
		}
	}

	this.addTextToDiv = function() {
		this.leText = document.createElement("span");
		this.leText.innerHTML = this.value;
		var _this = this;
		dojo.event.connect(this.leText, "onclick", this, "toggleInput");
		this.liveEditDiv.appendChild(this.leText);
	}

	this.addInputToForm = function() {
		this.leInput = document.createElement("input")
		this.leInput.type = "text";
		this.leInput.name = "update_value";
		this.leInput.value = this.value;
		this.leInput.size = this.value.length + 10;
		this.leInput.className = this.css_class;
		dojo.event.connect(this.leInput, "onblur", this, "saveChanges");
		dojo.event.connect(this.leInput, "onkeydown", this, "keyDown");
		this.liveEditForm.appendChild(this.leInput);
		this.leInput.focus();
	}

	this.toggleInput = function() {
		this.liveEditDiv.className = this.className + " active";
		this.liveEditDiv.removeChild(this.leText);
		this.addInputToForm();
	}

	this.addHiddenFieldsToForm = function() {
		var aid = document.createElement("input");
		aid.type = "hidden";
		aid.name = "artobject_id";
		aid.value = this.artobject_id;
		this.liveEditForm.appendChild(aid);
		var fkey = document.createElement("input");
		fkey.type = "hidden";
		fkey.name = "field_key";
		fkey.value = this.field_key;
		this.liveEditForm.appendChild(fkey);
		var oldvalue = document.createElement("input");
		oldvalue.type = "hidden";
		oldvalue.name = "old_value";
		oldvalue.value = this.value;
		this.liveEditForm.appendChild(oldvalue);
	}

	this.saveChanges = function(evt) {
		var form = this.liveEditForm;
		var _this = this;
		dojo.io.bind({
			url: this.update_url,
			formNode: form,
			load: function(type, data, event) {
				_this.liveEditForm.removeChild(_this.leInput);
				_this.value = data['updated_value'];
				_this.leText.innerHTML = data['updated_value'];
				_this.liveEditDiv.appendChild(_this.leText);
				_this.liveEditDiv.className = _this.className;
			},
			mimetype: "text/json"
		});	
		this.value = _this.value; 
		evt.preventDefault();
	}
}

dojo.inherits(ywesee.widget.LiveEdit, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:liveedit");
