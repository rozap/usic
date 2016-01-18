var _ = require('underscore');
var View = require('./view');
var Session = require('./models/session');

var LoginTemplate = require('./templates/login.html');

module.exports = View.extend({
  el: '#auth',
  template: _.template(LoginTemplate),

  events: {
    'click .login': 'onLogin',
    'keyup': 'onKeyUp'
  },

  init: function(opts) {
    this.model = new Session({}, opts);
    this.api.session = this.model;
    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.model, 'error', this.onError);
    this.listenTo(this.dispatcher, 'input:onConfirm', this.onLogin);
    this.render();
  },

  onLogin: function() {
    this.model.set(this.serializeForm()).save();
  },

  onSuccess: function() {
    this.model.persistLocally();

    this.setState({
      success: true
    });
  },

  onError: function(error) {
    this.setState({
      error: error
    });
  },



});