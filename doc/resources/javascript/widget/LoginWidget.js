dojo.provide("ywesee.widget.LoginWidget");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");

dojo.widget.defineWidget(
	"ywesee.widget.LoginWidget",
	dojo.widget.HtmlWidget,
	{
		templatePath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlLoginWidget.html"),
		templateCssPath: dojo.uri.dojoUri("../javascript/widget/templates/HtmlLoginWidget.css"),

		//widget variables
		loginLink: null,
		oldOnclick: "",
		loginFormUrl: "",
		widgetDiv: "",

		//widget attach points
		widgetContainer: null,
		errorMessageContainer: null,
		formContainer: null,

		fillInTemplate: function() {
			_this = this;
			dojo.io.bind({
				url: this.loginFormUrl,	
				mimetype: "text/html",
				load: function(type, data, event) {
					_this.formContainer.innerHTML = data;		
					var pos = dojo.html.getAbsolutePosition(_this.loginLink, true);
					var left = pos[0];
					var top = pos[1] - 20 - _this.formContainer.offsetHeight;
					_this.widgetContainer.style.left = left+"px";
					_this.widgetContainer.style.top = top+"px";
					_this.loginForm = _this.formContainer.firstChild;
					dojo.event.connect(_this.loginForm, 'onsubmit', _this, 'submitForm');
					var cancel = dojo.byId('login-form-cancel-button');
					dojo.event.connect(cancel, 'onclick', _this, 'cancelLogin');
				}
			});
		/*
			this.login_form_div = dojo.byId('login-form-div');
			this.loginLink.className = this.link_css_class;
			this.loginLink.style.cssFloat = 'left';
			//this.loginLink.style.display = 'inline';
			this.loginLink.href = 'javascript:void(0)';
			this.loginLink.innerHTML = this.link_value;
			dojo.event.connect(this.loginLink, 'onclick', this, "toggleLoginForm");
			*/
		},

		cancelLogin: function() {
			this.loginLink.onclick = this.oldOnclick;
			this.destroy();	
		},

		submitForm: function() {
			_this = this;
			dojo.io.bind({
				url: this.loginForm.action,
				formNode: this.loginForm,
				load: function(type, data, event) {
					if(data['success']) {
						document.location.reload();
					} else {
						_this.errorMessageContainer.innerHTML = data['message'];
					}
				},
				mimetype: "text/json"
			});		
		}

	}
);
