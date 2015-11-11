 var Model = require('./model');

 module.exports = Model.extend({
  name: 'user',

  _onSync:function() {
    this.unset('password')
  }
 });