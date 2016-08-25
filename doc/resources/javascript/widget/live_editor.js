define([
  'dojo/_base/declare'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'ywesee/widget/live_input_text'
, 'ywesee/widget/live_textarea'
, 'ywesee/widget/live_button'
], function(declare, _wb, _tm, lvit, lvta, lvbtn) {
  return declare('ywesee.widget.live_editor', [_wb, _tm], {
    // attributes
    baseClass:    'live-editor-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/live_editor.html')
    // edit widget variables
  , imageDiv: null
    // input widget variables
  , update_url:       ''
  , values:           []
  , image_pos:        0
  , labels:           false
  , element_id_name:  ''
  , element_id_value: ''
    // edit button widget variables
  , delete_icon_src:       ''
  , delete_icon_txt:       ''
  , delete_image_icon_src: ''
  , delete_image_icon_txt: ''
  , add_image_icon_src:    ''
  , add_image_icon_txt:    ''
  , edit_widget:           ''
  , has_image:             ''
  , image_url:             ''
  , delete_item_url:       ''
  , delete_image_url:      ''
  , upload_form_url:       ''
    // attach points
  , editWidgetContainer:  null
  , elementContainer:     null
  , editButtonsContainer: null
    // callbacks
  , constructor: function(params, srcNodeRef) {
      // pass
    }
  , startup: function() {
      if (this.labels) {
        for (idx = 0; idx < this.values.length; idx += 3) {
          var key = this.values[idx]
            , val = this.values[idx + 1]
            , lbl = this.values[idx + 2]
            ;
          this.addInputText(val, key, lbl);
        }
      } else {
        for (idx = 0; idx < this.values.length; idx += 2) {
          var key = this.values[idx]
            , val = this.values[idx + 1]
            ;
          this.addInputText(val, key, '');
        }
      }
      this.handleImage();
      this.addEditButtons();
    }
  , addInputText: function(value, str, label) {
      value = value.replace(/<comma[^>]*>/g, ',');
      var inputDiv = document.createElement('div');
      this.elementContainer.appendChild(inputDiv);
      var properties = {
        element_id_name:  this.element_id_name
      , element_id_value: this.element_id_value
      , old_value:        value
      , css_class:        'block-' + str
      , update_url:       this.update_url
      , field_key:        str
      , labels:           this.labels
      , label:            label
      };
      var widget;
      if (value.length > 30) {
        widget = new lvta(properties, inputDiv);
      } else {
        widget = new lvit(properties, inputDiv);
      }
      widget.startup();
    }
  , handleImage: function() {
      if (this.has_image == 'true') {
        this.imageDiv = document.createElement('div');
        this.imageDiv.className = 'block-image';
        var img  = document.createElement('img')
          , node = this.elementContainer.childNodes[this.image_pos]
          ;
        img.src = this.image_url;
        this.imageDiv.appendChild(img);
        if (node == 'undefined') {
          this.elementContainer.appendChild(this.imageDiv);
        } else {
          this.elementContainer.insertBefore(this.imageDiv, node);
        }
      } else {
        if (this.imageDiv) {
          this.elementContainer.removeChild(this.imageDiv);
          this.imageDiv = null;
        }
      }
    }
  , addEditButtons: function() {
      var buttonDiv = document.createElement('div');
      this.editButtonsContainer.appendChild(buttonDiv);
      var widget = new lvbtn({
        delete_icon_src:       this.delete_icon_src
      , delete_icon_txt:       this.delete_icon_txt
      , delete_image_icon_src: this.delete_image_icon_src
      , delete_image_icon_txt: this.delete_image_icon_txt
      , add_image_icon_src:    this.add_image_icon_src
      , add_image_icon_txt:    this.add_image_icon_txt
      , edit_widget:           this
      , element_id_value:      this.element_id_value
      , has_image:             this.has_image
      , delete_item_url:       this.delete_item_url
      , delete_image_url:      this.delete_image_url
      , upload_form_url:       this.upload_form_url
      }, buttonDiv);
      widget.startup();
    }
  });
});
