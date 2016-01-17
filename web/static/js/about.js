var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');

var AboutTemplate = require('./templates/about.html');

module.exports = View.extend({
  el: '#main',
  template: _.template(AboutTemplate),

  init: function(opts) {
    this.render();
  }
});