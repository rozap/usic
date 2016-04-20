var _ = require('underscore');
var View = require('./view');

var TagMapTemplate = require('./templates/tag-map.html');


module.exports = View.extend({
  template: _.template(TagMapTemplate),

  init: function(opts) {
    this.listenTo(this.model, 'change', this.r);
    this.render();
  },
});