define([
  'dojo/_base/declare'
, 'dojo/on'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'ywesee/widget/live_input'
], function(declare, on, _wb, _tm, _li) {
  return declare('ywesee.widget.live_input_text', [_wb, _tm, _li], {
    // attributes
    baseClass:    'live-input-text'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/live_input.html')
    // callbacks
  , constructor: function(params, srcNodeRef) {
      // pass
    }
  , addInputToForm: function() {
      var _this = this;
      this.leInput           = document.createElement('input');
      this.leInput.type      = 'text';
      this.leInput.name      = 'update_value';
      this.leInput.value     = this.old_value;
      this.leInput.className = this.css_class + ' live-edit active';
      this.leInput.id        = this.element_id_value + '-' + this.field_key;

      on(this.leInput, 'keydown', function(e) {
        _this.keyDown(e);
      });

      this.inputForm.appendChild(this.leInput);
      this.leInput.focus();
    }
  });
});
