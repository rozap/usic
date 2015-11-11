var bb = require('backbone');

var Register = require('./register');
var Login = require('./login');
var Transcriptions = require('./transcriptions');

module.exports = bb.Router.extend({
  routes: {
    '': 'index',
    'login': 'login',
    'register': 'register',
    'song/:uid': 'song',
    'transcriptions/:page': 'transcriptions'
  },

  initialize: function(opts) {
    this._opts = opts;
  },

  start: function() {
    if (this._isStarted) return;
    bb.history.start();
    this._isStarted = true;
  },

  index: function() {
    console.log("route", "index");
    this.reset();
  },

  reset: function() {
    if (this._authView) this._authView.destroy();
  },

  login: function() {
    this.reset();
    this._authView = new Login(this._opts);
    console.log("route", "login");
  },

  register: function() {
    this.reset();
    this._authView = new Register(this._opts);
    console.log("route", "register");
  },

  song: function(uid) {
    console.log("route", "song");
  },

  transcriptions: function(page) {
    console.log("route", "transcriptions");
    this._mainView = new Transcriptions(this._opts);
  }
});