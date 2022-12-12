define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
], function(declare, xhr) {
  return declare('ywesee.widget.show', [], {
    // properties
    dataType:     'json'
  , anchor:       ''
  , dataUrl:      ''
  , images:       []
  , titles:       []
  , serieId:      ''
  , artObjectIds: []
  , artGroupIds:  []
    // callbacks
  , startup: function() {
      this.build();
    }
  , build: function(url) {
      var _this = this;
      if (_this.dataUrl && _this.images.length === 0) {
        _this.fetch(_this.dataUrl, function(data, req) {
            _this.dataUrl      = data.dataUrl
          , _this.images       = data.images
          , _this.titles       = data.titles
          , _this.serieId      = data.serieId
          , _this.artObjectIds = data.artObjectIds
          , _this.artGroupIds  = data.artGroupIds
          ;
          _this.setup();
        });
      } else {
        _this.setup();
      }
    }
  , fetch: function(url, callback) {
      var _this = this;
      url = url.replace('http://', '//');
      xhr.get({
        url:      url
      , handleAs: _this.dataType
      ,load:      callback
      });
    }
  , setup: function() {
      // implement in each widgets
    }
  });
});
