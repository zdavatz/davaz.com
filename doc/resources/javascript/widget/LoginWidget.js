dojo.provide("ywesee.widget.LoginWidget");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");

dojo.declare(
	"ywesee.widget.LoginWidget",
	[dijit._Widget, dijit._Templated],
	{
    templatePath: 
      dojo.moduleUrl("ywesee.widget", "templates/HtmlLoginWidget.html"),

		//widget variables
		loginLink: null,
		oldOnclick: "",
		loginFormUrl: "",
		widgetDiv: "",

		//widget attach points
		widgetContainer: null,
		errorMessageContainer: null,
		formContainer: null,

		startup: function() {
			_this = this;
			dojo.xhrGet({
				url: this.loginFormUrl,	
				handleAs: "text",
				load: function(data, request) {
					_this.formContainer.innerHTML = data;		
					var pos = dojo.coords(_this.loginLink, true);
					var left = pos.x;
          // display near the "login" link see davaz.css
					//var top = pos.y - 20 - _this.formContainer.offsetHeight;
					//_this.widgetContainer.style.position = "absolute";
					//_this.widgetContainer.style.top = top+"px";
					_this.widgetContainer.style.left = left+"px";
					_this.loginForm = _this.formContainer.firstChild;
					dojo.connect(_this.loginForm, 'onsubmit', _this, 'submitForm');
					var cancel = dojo.byId('login-form-cancel-button');
					dojo.connect(cancel, 'onclick', _this, 'cancelLogin');
				}
			});
		},

		cancelLogin: function() {
			this.loginLink.onclick = this.oldOnclick;
			this.destroy();	
		},

		submitForm: function() {
			_this = this;
			dojo.xhrPost({
				url: this.loginForm.action,
				form: this.loginForm,
				load: function(data, event) {
					if(data["success"]) {
						document.location.reload();
					} else {
						_this.errorMessageContainer.innerHTML = data.message;
					}
				},
				handleAs: "json-comment-filtered"
			});		
		}
	}
);
