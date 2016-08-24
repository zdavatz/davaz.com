define([
  'dojo/_base/declare'
, 'dojo/on'
, 'dojo/dom-construct'
, 'dijit/form/ToggleButton'
, 'dijit/_editor/_Plugin'
], function(declare, on, cnst, btn, _plgin) {
  return declare('ywesee.widget.live_editor_plugin', [_plgin], {
    // attributes
    baseClass: 'live-editor-plugin'
    // properties
  , useDefaultCommand: false
  , command:           'inserthtml'
  , _inHtmlMode:       false
  , _htmlEditNode:     null
    // callbacks
  , _initButton:       function() {
      if (!this.button) {
        var props = {
          label:     '&lt;html&gt;'
        , showLabel: true
        , iconClass: ''
        };
        this.button = new btn(props);

        var _this = this;
        on(this.button, 'click', function() {
          _this.toggleHtmlEditing();
        });
      }
    }
  , toggleHtmlEditing: function() {
      var e = this.editor;
      if (!this._inHtmlMode) {
        this._inHtmlMode = true;
        if (!this._htmlEditNode) {
          this._htmlEditNode = document.createElement('textarea');
          cnst.place(this._htmlEditNode, e.editingArea, 'after');
        }
        e.editingArea.style.display = 'none';
        var node = this._htmlEditNode;
          node.value         = e.getValue(true)
        , node.style.display = ''
        , node.style.width   = '100%'
        , node.style.height  = '300px'
        ;
      } else {
        this._inHtmlMode = false;
        this._htmlEditNode.style.display = 'none';
        this.pushValue();
          e.editingArea.style.display = ''
        , e.editingArea.focus()
        ;
      }
    }
  , pushValue: function() {
      this.editor.replaceValue(this._htmlEditNode.value);
    }
  });
});
