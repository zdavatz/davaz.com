define([
  'dojo/_base/declare'
, 'dojo/ready'
, 'dojo/parser'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'dijit/_WidgetsInTemplateMixin'
, 'ywesee/widget/show'
], function(declare, ready, parser, _wb, _tm, _witm, _sw) {
  declare('ywesee.widget.rack', [_wb, _tm, _sw], {
    // attributes
    baseClass:    'rack-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/rack.html')
  , view:         'rack'
    // properties
  , dataUrl:      ''
  , images:       []
  , titles:       []
  , artObjectIds: []
    // dom nodes
  , imageContainer:      null
  , thumbContainer:      null
  , imageTitleContainer: null
  , imageTitle:          null
  , displayImage:        null
    // states
  , toggleBusy:   false
    // callbacks
  , constructor: function(params, srcNodeRef) {
      // pass
    }
  , build: function() {
      this.inherited(arguments);
    }
  , setup: function(data) {
      var imageCount   = this.images.length
        , columnsCount = Math.floor(Math.sqrt(imageCount))
        , rowsCount    = Math.ceil(imageCount / columnsCount)
        , cWidth  = Math.floor((349 / columnsCount) - 8)
        , rHeight = Math.floor((349 / rowsCount) - 8)
        ;
      this.fillInDisplay();
      this.fillInThumbContainer(imageCount, cWidth, rHeight);
    }
  , fillInDisplay: function() {
      if (this.displayImage == null) { return; }
      if (!this.images[0] || !this.titles[0]) { return; }
      this.displayImage.src     = this.images[0];
      this.imageTitle.innerHTML = this.titles[0];
    }
  , toggleDisplay: function(img) {
      if (this.toggleBusy) { return; }
      if (this.displayImage.src == img.src) { return; }
      /* No fading desired */
      this.displayImage.src = img.src;
      this.displayImage.alt = img.alt;
      this.imageTitle.innerHTML = img.alt;
    }
  , fillInThumbContainer: function(imageCount, cWidth, rHeight) {
      for (idx = 0; idx < imageCount; idx++) {
        var div = document.createElement('div');
        div.style.width  = cWidth + 'px';
        div.style.height = rHeight + 'px';
        var img = document.createElement('img')
        img.name        = this.artObjectIds[idx];
        img.src         = this.images[idx];
        img.style.width = '180px';
        img.alt         = this.titles[idx];
        var _this = this;
        img.onmouseover = function() {
          _this.toggleDisplay(this);
        };
        div.appendChild(img);
        this.thumbContainer.appendChild(div);
      }
    }
  , refill: function(data) {
      var thumbs     = this.thumbContainer
        , imageCount = this.images.length
        ;
      for (idx = 0; idx < imageCount; idx++) {
        thumbs.removeChild(thumbs.childNodes[0]);
      }
      for (name in data) {
        this[name] = data[name];
      }
      this.fillInTemplate();
    }
  });
  ready(function() {
    parser.parse();
  });
});
