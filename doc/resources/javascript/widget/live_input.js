define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
, 'dojo/_base/lang'
, 'dojo/dom'
, 'dojo/on'
], function(declare, xhr, lang, dom, on) {
  return declare('ywesee.widget.live_input', [], {
    // attributes
    baseClass:    'live-input-widget'
    //widget variables
  , element_id_name:  ''
  , element_id_value: ''
  , old_value:        ''
  , css_class:        ''
  , update_url:       ''
  , field_key:        ''
  , leText:           null
  , leButtons:        null
  , leInput:          null
  , labels:           false
  , label:            ''
    // connection handlers
  , divConn:   null
  , labelConn: null
  , textConn:  null
    // attach points
  , inputContainer: null
  , labelDiv:       null
  , inputDiv:       null
  , inputForm:      null
    // callbacks
  , startup: function() {
      this.prepareWidget();
    }
  , prepareWidget: function() {
      this.inputDiv.className = this.css_class + ' live-edit';
      this.addTextToDiv();
      this.addHiddenFieldsToForm();
    }
  , keyDown: function(evt) {
      if (evt.keyCode == 27) { // escape key
        this.cancelInput();
      }
    }
  , cancelInput: function() {
      this.inputDiv.className = this.css_class + ' live-edit';
      this.labelDiv.className = 'label';
      this.inputForm.removeChild(this.leInput);
      this.inputContainer.removeChild(this.leButtons);
      this.addTextToDiv();
    }
  , addTextToDiv: function() {
      var _this = this;
      if (this.labels) {
        this.labelDiv.innerHTML        = this.label;
        this.inputDiv.style.marginLeft = '80px';
        this.labelConn = on(this.labelDiv, 'click', function(e) {
          _this.toggleInput(e);
        });
      }
      this.leText = document.createElement('span');
      this.leText.id        = this.element_id_value + '-' + this.field_key;
      this.leText.innerHTML = this.toHtml(this.old_value);
      this.divConn  = on(this.inputDiv, 'click', function(e) {
        _this.toggleInput(e);
      });
      this.textConn = on(this.leText, 'click', function(e) {
        _this.toggleInput(e);
      });
      this.inputDiv.appendChild(this.leText);
    }
  , addInputToForm: function() {
      // stub function to be filled by live-input-text or live-textarea widgets
    }
  , toggleInput: function() {
      if (this.labelConn) { this.labelConn.remove(); }
      if (this.divConn) { this.divConn.remove(); }
      if (this.textConn) { this.textConn.remove(); }
      this.inputDiv.className = this.css_class + ' live-edit active';
      this.inputDiv.removeChild(this.leText);
      this.addInputToForm();
      this.addButtonsToContainer();
    }
  , addButtonsToContainer: function() {
      var _this = this;
      this.leButtons = document.createElement('div');
      this.leButtons.className = 'edit-buttons';
      if (this.labels) {
        this.leButtons.style.marginLeft = '80px';
      }
      var submit = document.createElement('input');
        submit.type  = 'button'
      , submit.value = 'Save'
      ;
      on(submit, 'click', function(e) {
        _this.saveChanges(e);
      });

      this.leButtons.appendChild(submit);

      var cancel = document.createElement('input');
        cancel.type  = 'button'
      , cancel.value = 'Cancel'
      ;
      on(cancel, 'click', function(e) {
        _this.cancelInput(e);
      });

      this.leButtons.appendChild(cancel);
      this.inputContainer.appendChild(this.leButtons);
    }
  , addHiddenFieldsToForm: function() {
      var eid = document.createElement('input');
        eid.type  = 'hidden'
      , eid.name  = this.element_id_name
      , eid.value = this.element_id_value
      ;
      this.inputForm.appendChild(eid);
      var fkey = document.createElement('input');
        fkey.type  = 'hidden'
      , fkey.name  = 'field_key'
      , fkey.value = this.field_key
      ;
      this.inputForm.appendChild(fkey);
      var oldvalue = document.createElement('input');
        oldvalue.type  = 'hidden'
      , oldvalue.name  = 'old_value'
      , oldvalue.value = this.old_value
      ;
      this.inputForm.appendChild(oldvalue);
    }
  , toHtml: function(strText) {
      strText = String(strText);
      var strTarget    = '\n'
        , strSubString = '<br />'
        , intIndexOfMatch = strText.indexOf(strTarget)
        ;
      while (intIndexOfMatch != -1) {
        strText         = strText.replace(strTarget, strSubString);
        intIndexOfMatch = strText.indexOf(strTarget);
      }
      return(strText);
    }
  , saveChanges: function(evt) {
      var _this = this;
      var form = this.inputForm;
      xhr.post({
        url:      this.update_url
      , handleAs: 'json'
      , form:     form
      , load:     lang.hitch(this, 'saveSuccess')
      });
      evt.preventDefault();
    }
  , saveSuccess: function(data, request) {
      this.old_value        = data['updated_value'];
      this.leText.innerHTML = this.toHtml(data['updated_value']);
      // hack for tooltip
      if (data['link_id'] && data['from_url']) {
        var link = dom.byId('tooltip_from_artobject_' + data['link_id'])
        if (data['from_url'] == 'unknown') {
          link.href      = '';
          link.innerHTML = 'unknown';
        } else {
          link.href      = data['from_url'];
          link.innerHTML = data['from_url'];
        }
      }
      if (data['link_id'] && data['to_url']) {
        var link = dom.byId('tooltip_to_artobject_' + data['link_id'])
        if (data['to_url'] == 'unknown') {
          link.href      = '';
          link.innerHTML = 'unknown';
        } else {
          link.href      = data['to_url'];
          link.innerHTML = data['to_url'];
        }
        var div = link.parentNode.nextSibling;
        if (div) {
          var img = div.getElementsByTagName('img')[0];
          if (data['tooltip_src']) {
            if (!img) {
              img = document.createElement('img');
              img.setAttribute('class', 'image-tooltip-image');
              div.firstChild.firstChild.appendChild(img);
            }
            img.src = data['tooltip_src'];
          }
        }
      }
      this.cancelInput();
    }
  });
});
