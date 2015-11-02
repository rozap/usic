var _ = require('underscore');
var View = require('./view');

var LoginTemplate = require('./templates/login.html');

module.exports = View.extend({
  el: '#auth',
  template: _.template(LoginTemplate),

  events: {
    'click .login': 'onLogin'
  },

  init:function( ){
    this.render()
  },

  //
  // make session in db. session <-> user
  // session key in local storage
  // session key
  onLogin: function() {

  }

})