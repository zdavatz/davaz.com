dojo.provide("ywesee.widget.GuestbookWidget");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.declare(
	"ywesee.widget.GuestbookWidget",
	[dijit._Widget, dijit._Templated],
	{
    templatePath: dojo.moduleUrl("ywesee.widget", "templates/HtmlGuestbookWidget.html"),

		//widget variables
		form_url: "",
		form_node: "",

		//dojo attach points
		guestbookWidgetContainer: null,
		addEntryLink: null,
		formContainer: null,
		errorMessages: null,

		startup: function() {
			this.formContainer.style.display = "none";
			var _this = this;
      
			dojo.xhrPost({
				url: this.form_url,
				handleAs: "text",
				load: function(data, request) {
					_this.formContainer.innerHTML = data;	
					_this.form_node = _this.formContainer.firstChild;
					dojo.connect(_this.form_node, 'onsubmit', _this, 'submitForm');
					var cancelButton = dojo.byId('cancel-add-entry');
					dojo.connect(cancelButton, 'onclick', _this, 'toggleForm');
				}
			});
     
		},

		toggleForm: function() {
			if(this.formContainer.style.display == "block") {
				var _this = this;
				var callback = function() {
					_this.errorMessages.innerHTML = "";
					_this.addEntryLink.style.display = 'block';
				}
				dojo.fx.wipeOut({node:this.formContainer,duration:300,onEnd:callback}).play();
			} else {
				this.addEntryLink.style.display = 'none';
				dojo.fx.wipeIn({node:this.formContainer,duration:300}).play();
			}
		},	

		submitForm: function() {
			var _this = this;
			dojo.xhrPost({
				url: this.form_node.action,
				form: this.form_node,
				handleAs: "json-comment-filtered",
				load: function(data, request) {
					if(data["success"])	{
						document.location.reload();
					} else {
						_this.errorMessages.innerHTML = data['messages'];
					}
				}
			});		
		}
		
	}
);
