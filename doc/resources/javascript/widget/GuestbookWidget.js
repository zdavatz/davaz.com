dojo.provide("ywesee.widget.GuestbookWidget");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");
dojo.require("dojo.validate");

dojo.widget.defineWidget(
	"ywesee.widget.GuestbookWidget",
	dojo.widget.HtmlWidget,
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlGuestbookWidget.html"),

		//widget variables
		form_url: "",
		form_node: "",

		//dojo attach points
		guestbookWidgetContainer: null,
		addEntryLink: null,
		formContainer: null,
		errorMessages: null,

		fillInTemplate: function() {
			this.formContainer.style.display = "none";
			var _this = this;
			dojo.io.bind({
				url: this.form_url,
				mimetype: "text/html",
				load: function(type, data, event) {
					_this.formContainer.innerHTML = data;	
					_this.form_node = _this.formContainer.firstChild;
					dojo.event.connect(_this.form_node, 'onsubmit', _this, 'submitForm');
				},
			});
		},

		toggleForm: function() {
			if(this.formContainer.style.display == "block") {
				dojo.lfx.wipeOut(this.formContainer, 300).play();
			} else {
				dojo.lfx.wipeIn(this.formContainer, 300).play();
			}
		},	

		submitForm: function() {
			var _this = this;
			dojo.io.bind({
				url: this.form_node.action,
				formNode: this.form_node,
				mimetype: "text/json",
				load: function(type, data, event) {
					if(data['success'])	{
						document.location.reload();
					} else {
						_this.errorMessages.innerHTML = data['messages'];
					}
				},
			});		
		},
		
	}
);
