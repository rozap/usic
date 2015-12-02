var _ = require('underscore');
var View = require('./view');

var User = require('./models/user');
var Session = require('./models/session');
var RegisterTemplate = require('./templates/register.html');


module.exports = View.extend({
  el: '#auth',
  template: _.template(RegisterTemplate),

  events: {
    'click .register': 'onRegister'
  },

  init: function(opts) {
    this.model = new User({}, opts);
    this.sesh = new Session({}, opts);

    this.listenTo(this.sesh, 'sync', this.onLoginSuccess);
    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.sesh, 'error', this.onError);
    this.listenTo(this.model, 'error', this.onError);

    this.listenTo(this.dispatcher, 'input:onConfirm', this.onRegister);
    this.render();
  },

  onRegister: function() {
    this.model.set(this.serializeForm());
    this.sesh.set({
      password: this.model.get('password'),
      email: this.model.get('email')
    });
    this.model.save();
  },

  onSuccess: function() {
    this.sesh.save();
  },

  onLoginSuccess: function() {
    this.sesh.persistLocally();

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