dojo.provide("ywesee.widget.EditWidget");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");
dojo.require("ywesee.widget.Input");
dojo.require("ywesee.widget.InputText");
dojo.require("ywesee.widget.InputTextArea");

dojo.widget.defineWidget(
	"ywesee.widget.EditWidget",
	dojo.widget.HtmlWidget, 
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlEditWidget.html"),

		//edit widget variables
		imageDiv: null,

		//input widget variables
		update_url: "",
		values: [],
		image_pos: 0,
		labels: false,
		element_id_name: "",
		element_id_value: "",

		//edit button widget variables
		delete_icon_src: "",
		delete_icon_txt: "",
		delete_image_icon_src: "",
		delete_image_icon_txt: "",
		add_image_icon_src: "",
		add_image_icon_txt: "",
		edit_widget: "",
		has_image: "",
		image_url: "",
		delete_item_url: "",
		delete_image_url: "",
		upload_form_url: "",
		
		//attach points
		editWidgetContainer: null,
		elementContainer: null,
		editButtonsContainer: null,
		
		fillInTemplate: function() {
			if(this.labels) {
				for(idx = 0; idx < this.values.length; idx += 3) {
					key = this.values[idx];
					value = this.values[idx + 1];
					label = this.values[idx + 2]
					this.addInputText(value, key, label);
				}
			} else {
				for(idx = 0; idx < this.values.length; idx += 2) {
					key = this.values[idx];
					value = this.values[idx + 1];
					this.addInputText(value, key, "");
				}
			}
			this.handleImage();
			this.addEditButtons();
		},

		addInputText: function(value, str, label) {
			var inputDiv = document.createElement("div");
			this.elementContainer.appendChild(inputDiv);
			var widgetName = "InputText" 
			if(value.length > 30) {
				widgetName = "InputTextArea";
			}
			dojo.widget.createWidget(widgetName, 
				{ 
					element_id_name: this.element_id_name, 
					element_id_value: this.element_id_value, 
					old_value: value, 
					css_class: "block-" + str, 
					update_url: this.update_url,
					field_key: str,
					labels: this.labels,
					label: label,
				},
				inputDiv	
			);
		},

		handleImage: function() {
			if(this.has_image == 'true') {
				this.imageDiv = document.createElement("div");
				this.imageDiv.className = "block-image";
				var img = new Image;	
				img.src = this.image_url;
				this.imageDiv.appendChild(img);
				var node = this.elementContainer.childNodes[this.image_pos];
				if(node == 'undefined') { 
					this.elementContainer.appendChild(this.imageDiv);
				} else {
					this.elementContainer.insertBefore(this.imageDiv, node);
				}
			}	else {
				if(this.imageDiv) {
					this.elementContainer.removeChild(this.imageDiv);
					this.imageDiv = null;
				}
			}
		},

		addEditButtons: function() {
			var buttonDiv = document.createElement("div");
			this.editButtonsContainer.appendChild(buttonDiv);
			dojo.widget.createWidget("EditButtons", 
				{ 
					delete_icon_src: this.delete_icon_src,
					delete_icon_txt: this.delete_icon_txt,
					delete_image_icon_src: this.delete_image_icon_src,
					delete_image_icon_txt: this.delete_image_icon_txt,
					add_image_icon_src: this.add_image_icon_src,
					add_image_icon_txt: this.add_image_icon_txt,
					edit_widget: this,
					has_image: this.has_image,
					delete_item_url: this.delete_item_url,
					delete_image_url: this.delete_image_url,
					upload_form_url: this.upload_form_url,
				},
				buttonDiv	
			);

		},
	}
);
