define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
, 'dojo/on'
, 'dojo/dom'
, 'dojo/fx'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
], function(declare, xhr, on, dom, fx, _wb, _tm) {
  return declare('ywesee.widget.guestbook', [_wb, _tm], {
    // attributes
    baseClass:    'guestbook-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/guestbook.html')
    // widget variables
  , form_url:  ''
  , form_node: ''
    // dojo attach points
  , guestbookWidgetContainer: null
  , addEntryLink:             null
  , formContainer:            null
  , errorMessages:            null
    // callbacks
  , constructor: function(params, srcNodeRef) {
      // pass
    }
  , startup: function() {
      this.formContainer.style.display = 'none';
      var _this = this;
      xhr.get({
        url:      this.form_url
      , handleAs: 'text'
      , load: function(data, request) {
          _this.formContainer.innerHTML = data;
          _this.form_node               = _this.formContainer.firstChild;
          var cancelButton = dom.byId('cancel_add_entry');
          on(_this.form_node, 'submit', function(e) {
            e.preventDefault();
            return _this.submitForm();
          });
          on(cancelButton, 'click', function(e) {
            e.preventDefault();
            return _this.toggleForm();
          });
        }
      });
    }
  , toggleForm: function() {
      if ((this.formContainer.style.display == '') ||
          (this.formContainer.style.display == 'block')) {
        var _this = this;
        var callback = function() {
          _this.errorMessages.innerHTML    = '';
          _this.addEntryLink.style.display = 'block';
        }
        fx.wipeOut({
          node:     this.formContainer
        , duration: 300
        , onEnd:    callback
        }).play();
      } else {
        this.addEntryLink.style.display = 'none';
        fx.wipeIn({
          node:     this.formContainer
        , duration: 300
        }).play();
      }
    }
  , submitForm: function() {
      var _this = this;
      xhr.post({
        url:      this.form_node.action
      , form:     this.form_node
      , handleAs: 'json'
      , load:     function(data, request) {
          if (data['success'])  {
            document.location.reload();
          } else {
            _this.errorMessages.innerHTML = data['messages'];
          }
          return data;
        }
      });
    }
  });
});
