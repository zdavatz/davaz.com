dojo.provide("ywesee.widget.EditButtons");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"ywesee.widget.EditButtons",
	dojo.widget.HtmlWidget,
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlEditButtons.html"),
		templateCssPath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlEditButtons.css"),

		//dojo variables
		delete_icon_src: "",
		delete_icon_txt: "",
		delete_image_icon_src: "",
		delete_image_icon_txt: "",
		add_image_icon_src: "",
		add_image_icon_txt: "",
		edit_widget: "",
		element_id_value: "", 
		has_image: "",
		delete_item_url: "",
		delete_image_url: "",
		upload_form_url: "",

		//dojo attachpoints
		editButtonsContainer: null,
		deleteLink: null,
		deleteIcon: null,
		imageButtonLink: null,
		imageButtonIcon: null,
		uploadImageFormDiv: null,
		uploadImageForm: null,

		fillInTemplate: function() {
			this.uploadImageFormDiv.style.display = "none";	
			
			this.deleteIcon.src = this.delete_icon_src;
			this.deleteIcon.title = this.delete_icon_txt;
			this.deleteIcon.alt = this.delete_icon_txt;
			this.deleteIcon.id = "delete-item-" + this.element_id_value;
			dojo.event.connect(this.deleteLink, 'onclick', this, 'deleteItem');
			this.handleImageButtons();
		},

		handleImageButtons: function() {
			if(this.has_image == 'true') {
				this.imageButtonIcon.src = this.delete_image_icon_src;
				this.imageButtonIcon.title = this.delete_image_icon_txt;
				this.imageButtonIcon.alt = this.delete_image_icon_txt;
				this.imageButtonIcon.id = "delete-image-" + this.element_id_value;
				dojo.event.disconnect(this.imageButtonLink, 'onclick', this, 'addUploadImageForm');
				dojo.event.connect(this.imageButtonLink, 'onclick', this, 'deleteImage');
			} else {
				this.imageButtonIcon.src = this.add_image_icon_src;
				this.imageButtonIcon.title = this.add_image_icon_txt;
				this.imageButtonIcon.alt = this.add_image_icon_txt;
				this.imageButtonIcon.id = "add-image-" + this.element_id_value;
				dojo.event.disconnect(this.imageButtonLink, 'onclick', this, 'deleteImage');
				dojo.event.connect(this.imageButtonLink, 'onclick', this, 'addUploadImageForm');
			}
		},

		deleteItem: function() {
			var msg = 'Do you really want to delete this Item?';
			_this = this;
			if(confirm(msg)) { 
				dojo.io.bind({
					url: this.delete_item_url,
					load: function(type, data, event) {
						if(data['status'] == 'deleted') {
							_this.edit_widget.destroy();
						}
					},
					mimetype: "text/json"
				});
			}
		},

		deleteImage: function() {
			var msg = 'Do you really want to delete this Image?';
				_this = this;
			if(confirm(msg)) { 
				dojo.io.bind({
					url: this.delete_image_url,
					load: function(type, data, event) {
						if(data['status'] == 'deleted') {
							_this.has_image = "false";
							_this.handleImageButtons();
							_this.edit_widget.has_image = "false";
							_this.edit_widget.handleImage();
						}
					},
					mimetype: "text/json"
				});
			}
		},

		addUploadImageForm: function() {
			_this = this;
			if(this.uploadImageFormDiv.style.display == 'none') {
				dojo.io.bind({
					url: this.upload_form_url,				
					load: function(type, data, event) {
						var container = _this.uploadImageFormDiv;
						container.innerHTML = data;
						_this.uploadImageForm = container.firstChild;
						dojo.event.connect(_this.uploadImageForm, 
							'onsubmit', _this, "submitForm");
						dojo.lfx.wipeIn(container, 300).play();
					}, 
					mimetype: "text/html"
				});
			} else {
				dojo.lfx.wipeOut(_this.uploadImageFormDiv, 300).play();
			}
		},

		submitForm: function() {
			var form = this.uploadImageForm;
			document.body.style.curser = 'progress';
			_this = this;
			dojo.io.bind({
				url: form.action,
				formNode: form,
				transport: 'IframeTransport',
				load: function(type, data, event) {
					if(data.body.innerHTML != 'not uploaded') {
						dojo.lfx.wipeOut(_this.uploadImageFormDiv, 300).play();
						_this.uploadImageFormDiv.removeChild(form);
						_this.has_image = "true";
						_this.handleImageButtons();
						_this.edit_widget.has_image = "true";
						_this.edit_widget.image_url = data.body.innerHTML;
						_this.edit_widget.handleImage();	
					}
					document.body.style.cursor = 'auto';		
				},
				error: function(type, error) {
					dojo.debug(dojo.errorToString(error));
				},
				mimetype: 'text/html'
			});
		}

	}
);
