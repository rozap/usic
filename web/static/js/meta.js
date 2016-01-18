var _ = require('underscore');
var View = require('./view');
var Song = require('./song');
var MetaTemplate = require('./templates/meta.html');

module.exports = View.extend({
  el: '#meta',
  template: _.template(MetaTemplate),

  init: function(opts) {
    this.listenTo(this.dispatcher, 'create:session:success', this.onAuth);
    this.listenTo(this.dispatcher, 'read:session:success', this.onAuth);
    this.listenTo(this.dispatcher, 'delete:session:success', this.onLogout);

    this.render();
  },

  onAuth: function(session) {
    this.updateState({
      session: session
    });
  },

  onLogout: function() {
    this.updateState({
      session: false
    });
  }
});