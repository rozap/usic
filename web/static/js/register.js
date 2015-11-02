var _ = require('underscore');
var View = require('./view');

var User = require('./models/user');
var RegisterTemplate = require('./templates/register.html');


module.exports = View.extend({
  el: '#auth',
  template: _.template(RegisterTemplate),

  events : {
    'click .register': 'onRegister'
  },

  init: function(opts) {
    this.model = new User({}, opts);
    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.model, 'error', this.onError);
    this.render();
  },

  onRegister:function() {
    this.model.set(this.serializeForm()).save();
  },

  onSuccess:function() {
    this.setState({
      success:true
    });
  },

  onError:function(error) {
    this.setState({
      error: error
    });
  }

});