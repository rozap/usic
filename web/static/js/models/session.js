 var Model = require('./model');

 module.exports = Model.extend({
   name: 'session',

   persistLocally: function() {
     localStorage['usic'] = JSON.stringify({
       token: this.get('token'),
       user: this.get('user')
     });
   },

   loadFromDisk: function() {
     try {
       var sesh = JSON.parse(localStorage['usic']);
       this.set(sesh);
     } catch (e) {
       //no session
     }
     return this;
   },

   _onSync: function() {
     this.unset('password');
   }
 });