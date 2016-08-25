define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
, 'dojo/on'
, 'dojo/fx'
, 'dojo/io/iframe'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'ywesee/widget/live_input'
], function(declare, xhr, on, fx, iframe, _wb, _tm, liveInput) {
  return declare('ywesee.widget.live_button', [_wb, _tm], {
    // attributes
    baseClass:    'live-editor-button'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/live_button.html')
    // dojo variables
  , delete_icon_src:       ''
  , delete_icon_txt:       ''
  , delete_image_icon_src: ''
  , delete_image_icon_txt: ''
  , add_image_icon_src:    ''
  , add_image_icon_txt:    ''
  , edit_widget:           ''
  , element_id_value:      ''
  , has_image:             ''
  , delete_item_url:       ''
  , delete_image_url:      ''
  , upload_form_url:       ''
    // dojo attachpoints
  , editButtonsContainer: null
  , deleteLink:           null
  , deleteIcon:           null
  , imageButtonLink:      null
  , imageButtonIcon:      null
  , uploadImageFormDiv:   null
  , uploadImageForm:      null
    // callbacks
  , startup: function() {
      var _this = this;
      this.uploadImageFormDiv.style.display = 'none';
      this.deleteIcon.src   = this.delete_icon_src;
      this.deleteIcon.title = this.delete_icon_txt;
      this.deleteIcon.alt   = this.delete_icon_txt;
      this.deleteIcon.id    = 'delete-item-' + this.element_id_value;
      on(this.deleteLink, 'click', function() {
        _this.deleteItem();
      });
      this.handleImageButtons();
    }
  , handleImageButtons: function() {
      var _this = this;
      if (this.has_image == 'true') {
        this.imageButtonIcon.src   = this.delete_image_icon_src;
        this.imageButtonIcon.title = this.delete_image_icon_txt;
        this.imageButtonIcon.alt   = this.delete_image_icon_txt;
        this.imageButtonIcon.id    = 'delete-image-' + this.element_id_value;
        if (this._imgBtnLnk) {
           this._imgBtnLnk.remove();
        }
        this._imgBtnLlnk = on(this.imageButtonLink, 'click', function() {
          _this.deleteImage();
        });
      } else {
        this.imageButtonIcon.src   = this.add_image_icon_src;
        this.imageButtonIcon.title = this.add_image_icon_txt;
        this.imageButtonIcon.alt   = this.add_image_icon_txt;
        this.imageButtonIcon.id    = 'add-image-' + this.element_id_value;
        if (this._imgBtnLnk) {
           this._imgBtnLnk.remove();
        }
        this._imgBtnLnk = on(this.imageButtonLink, 'click', function() {
          _this.addUploadImageForm();
        });
      }
    }
  , deleteItem: function() {
      var msg = 'Do you really want to delete this Item?';
      _this = this;
      if (confirm(msg)) {
        xhr.get({
          url:      this.delete_item_url
        , handleAs: 'json'
        , load:     function(data, request) {
            if (data.deleted) {
              _this.edit_widget.destroy();
            }
          }
        });
      }
    }
  , deleteImage: function() {
      var msg = 'Do you really want to delete this Image?';
        _this = this;
      if (confirm(msg)) {
        xhr.get({
          url:      this.delete_image_url
        , handleAs: 'json'
        , load:     function(data, request) {
            if (data['status'] == 'deleted') {
              _this.has_image = 'false';
              _this.handleImageButtons();
              _this.edit_widget.has_image = 'false';
              _this.edit_widget.handleImage();
            }
          }
        });
      }
    }
  , addUploadImageForm: function() {
      _this = this;
      if (this.uploadImageFormDiv.style.display == 'none') {
        xhr.get({
          url:      this.upload_form_url
        , handleAs: 'text'
        , load:     function(data, request) {
            var container = _this.uploadImageFormDiv;
            _this.uploadImageForm = container.firstChild;
            if (_this.uploadImageForm) {
              on(_this.uploadImageForm, 'submit', function() {
                _this.submitForm();
              });
            }
            container.innerHTML = data;
            fx.wipeIn({
              node:     container
            , duration: 300
            }).play();
          }
        });
      } else {
        fx.wipeOut({
          node:     _this.uploadImageFormDiv
        , duration: 300
        }).play();
      }
    }
  , submitForm: function() {
      var form = this.uploadImageForm;
      document.body.style.curser = 'progress';
      _this = this;
      iframe.send({
        url:      form.action
      , handleAs: 'html'
      , form:     form
      , load:     function(data, request) {
          if (data.body.innerHTML != 'not uploaded') {
            fx.wipeOut({
              node:     _this.uploadImageFormDiv
            , duration: 300
            }).play();
            _this.uploadImageFormDiv.removeChild(form);
            _this.has_image = 'true';
            _this.handleImageButtons();
            _this.edit_widget.has_image = 'true';
            _this.edit_widget.image_url = data.body.innerHTML;
            _this.edit_widget.handleImage();
          }
          document.body.style.cursor = 'auto';
        },
        error: function(type, error) {
          // pass
        }
      });
    }
  });
});
