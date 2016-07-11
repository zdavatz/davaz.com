define([
  'dojo/_base/declare'
, 'dojo/_base/xhr'
, 'dojo/ready'
, 'dojo/parser'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
], function(declare, xhr, ready, parser, _wb, _tm) {
  declare('ywesee.widget.desk', [_wb, _tm], {
    baseClass:    'desk-widget'
  , templatePath: require.toUrl(
      '/resources/javascript/widget/templates/desk.html')
  , view:          'desk'
  , images:        []
  , titles:        []
  , dataUrl:       ''
  , serieId:       ''
  , deskContainer: null
  , deskContent:   null
  , contentPane:   null
  , startup:       function() {
      var newDataUrl = this.dataUrl.replace(/ajax_rack/, 'ajax_desk');
      _this = this;
      xhr.get({
        url:      newDataUrl
      , handleAs: 'text'
      , load:     function(data, request) {
          _this.toggleInnerHTML(data);
        }
      });
    }
  , toggleInnerHTML: function(html) {
      this.deskContent.innerHTML = html;
      try {
        parser.parse(this.deskContent);
      } catch(e) {
        // pass
      }
    }
  });
});
