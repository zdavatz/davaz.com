define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
], function(declare, xhr) {
  return declare('ywesee.widget.Show', [], {
    images:  []
  , titles:  []
  , startup: function() {
      if (this.images.length === 0) {
        var _this = this;
        xhr.get({
          url:      this.dataUrl
        , handleAs: 'json'
        , load:     function(data, request) {
            _this.images = data.images;
            _this.titles = data.titles;
            _this.setup();
          }
        });
      } else {
        this.setup();
      }
    }
  });
});
