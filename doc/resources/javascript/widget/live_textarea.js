define([
  'dojo/_base/declare'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'dijit/Editor'
, 'dijit/_editor/plugins/LinkDialog'
, 'dijit/_editor/plugins/AlwaysShowToolbar'
, 'ywesee/widget/live_input'
, 'ywesee/widget/live_editor_plugin'
], function(declare, _wb, _tm, editor, _ld, _ast, _li, _lep) {
  return declare('ywesee.widget.live_textarea', [_wb, _tm, _li], {
    // attributes
    baseClass:    'live-textarea-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/live_input.html')
  , editor:       null
  , htmlPlugin:   null
    // callbacks
    // callbacks
  , constructor: function(params, srcNodeRef) {
      // pass
    }
  , addInputToForm: function() {
      this.leInput = document.createElement('input');
      this.leInput.name          = 'update_value';
      this.leInput.style.display = 'none';
      this.inputForm.appendChild(this.leInput);

      // does not use textarea
      var text = document.createElement('div');
        text.innerHTML = this.old_value
      , text.className = this.css_class + ' live-edit active'
      ;
      this.inputForm.appendChild(text);
      this.editor = new editor({
        // TODO: use 'dijit._editor.plugins.LinkDialog'
        extraPlugins: [
          'dijit._editor.plugins.AlwaysShowToolbar'
        ]
      }, text);
      this.editor.addPlugin('ywesee.widget.live_editor_plugin', 0);
      this.editor.startup();
      this.htmlPlugin = this.editor._plugins[0];
      this.editor.focus();
    }
  , cancelInput: function() {
      this.inherited('cancelInput', arguments);
      this.editor.destroy();
      this.inputForm.removeChild(this.inputForm.lastChild);
    }
  , saveChanges: function() {
      if (this.htmlPlugin._inHtmlMode) {
        this.htmlPlugin.toggleHtmlEditing();
      }
      this.leInput.value = this.editor.getValue();
      this.inherited('saveChanges', arguments);
    }
  });
});
