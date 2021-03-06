define([
  'dojo/_base/declare'
, 'dojo/_base/connect'
, 'dojo/_base/xhr'
, 'dojo/_base/html'
, 'dojo/dom'
, 'dojo/dom-style'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'dijit/_WidgetsInTemplateMixin'
], function(declare, connect, xhr, html, dom, styl, _wb, _tm, _witm) {
  declare('ywesee.widget.login', [_wb, _tm], {
    baseClass: 'login-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/login.html')
    // properties
  , loginLink:    null
  , loginFormUrl: ''
  , widgetDiv:    ''
    // dom nodes
  , widgetContainer:       null
  , errorMessageContainer: null
  , formContainer:         null
  , startup: function() {
      _this = this;
      xhr.get({
        url:      this.loginFormUrl
      , handleAs: 'text'
      , load:     function(data, request) {
          _this.formContainer.innerHTML = data;
          var pos  = html.coords(_this.loginLink, true)
            , left = pos.x
            ;
          var cancel = dom.byId('login_form_cancel_button');
          _this.widgetContainer.style.left = left + 'px';
          _this.loginForm                  = _this.formContainer.firstChild;
          connect.connect(_this.loginForm, 'onsubmit', _this, 'submitForm');
          connect.connect(cancel, 'onclick', _this, 'cancelLogin');
        }
      });
    }
  , cancelLogin: function() {
      this.destroy();
    }
  , submitForm: function() {
      _this = this;
      xhr.get({
        url:      this.loginForm.action.replace('http://', '//')
      , handleAs: 'json'
      , form:     this.loginForm
      , load:     function(data, event) {
          if (data['success']) {
            document.location.reload();
          } else {
            _this.errorMessageContainer.innerHTML = data.message;
          }
        }
      });
    }
  });
});
