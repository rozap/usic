var _ = require('underscore');
var View = require('./view');
var Song = require('./song');
var MetaTemplate = require('./templates/meta.html');

module.exports = View.extend({
  el: '#meta',
  template: _.template(MetaTemplate),

  init: function(opts) {
    this.render();
  },

  _update: function(state) {
  },

});