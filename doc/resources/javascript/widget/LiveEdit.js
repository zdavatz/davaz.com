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

	this.isContainer = false;
	this.widgetType = "LiveEdit";

	this.artobject_id = "";
	this.value = "";
	this.css_class = "";
	this.update_url = "";
	this.field_key = "";
	this.liveEditContainer = null;
	this.liveEditDiv = null;
	this.liveEditForm = null;
	this.leSpan = null;
	this.leInput = null;


	this.fillInTemplate = function() {
		if(this.value == '') {
			return 0;
		} else {
			this.liveEditContainer.className = this.css_class;
			this.addSpanToDiv();
			dojo.event.connect(this.liveEditForm, "onblur", this, "saveChanges");
			this.addHiddenFieldsToForm();
		}
	}

	this.addSpanToDiv = function() {
		this.leSpan = document.createElement("span");
		this.leSpan.innerHTML = this.value;
		var _this = this;
		dojo.event.connect(this.leSpan, "onclick", this, "toggleInput");
		this.liveEditDiv.appendChild(this.leSpan);
	}

	this.addInputToForm = function() {
		this.leInput = document.createElement("input")
		this.leInput.type = "text";
		this.leInput.name = "update_value";
		this.leInput.value = this.value;
		this.leInput.size = this.value.length + 10;
		this.leInput.className = 'live-edit-input';
		dojo.event.connect(this.leInput, "onblur", this, "saveChanges");
		this.liveEditForm.appendChild(this.leInput);
	}

	this.toggleInput = function() {
		this.liveEditDiv.removeChild(this.leSpan);
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
	}

	this.saveChanges = function(evt) {
		var form = this.liveEditForm;
		var _this = this;
		dojo.io.bind({
			url: this.update_url,
			formNode: form,
		//	transport: 'IframeTransport',
			load: function(type, data, event) {
				_this.liveEditForm.removeChild(_this.leInput);
				_this.value = data['updated_value'];
				_this.leSpan.innerHTML = data['updated_value'];
				_this.liveEditDiv.appendChild(_this.leSpan);
			},
			mimetype: "text/json"
		});	
		this.value = _this.value; 
		evt.preventDefault();
	}
}

dojo.inherits(ywesee.widget.LiveEdit, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:liveedit");
