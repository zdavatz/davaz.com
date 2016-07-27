define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
, 'dojo/ready'
, 'dojo/parser'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'ywesee/widget/show'
], function(declare, xhr, ready, parser, _wb, _tm, _sw) {
  declare('ywesee.widget.desk', [_wb, _tm, _sw], {
    // attributes
    baseClass:    'desk-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/desk.html')
  , view:         'desk'
    // properties
  , dataType: 'text'
  , dataUrl:  ''
    // dom nodes
  , deskContainer: null
  , deskContent:   null
  , contentPane:   null
    // callbacks
  , build: function() {
      var _this = this;
      // dataUrl will be used for next widget
      var url = _this.dataUrl.replace(/ajax_rack/, 'ajax_desk');
      _this.fetch(url, function(data, req) {
        _this.setup(data);
      });
    }
  , setup: function(data) {
      this.deskContent.innerHTML = data;
    }
  });
});
