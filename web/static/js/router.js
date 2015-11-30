var _ = require('underscore');
var bb = require('backbone');

var Register = require('./register');
var Login = require('./login');
var Transcriptions = require('./transcriptions');
var Me = require('./me');
var Song = require('./song');

module.exports = bb.Router.extend({
  routes: {
    '': 'index',
    'login': 'login',
    'register': 'register',
    'song/:uid': 'song',
    'me': 'me',
    'transcriptions/:page': 'transcriptions'
  },

  initialize: function(opts) {
    this._options = opts;
  },

  _opts:function(o){
    return _.extend(o || {}, this._options);
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
    if (this._main) this._main.destroy();
  },

  login: function() {
    this.reset();
    this._main = new Login(this._opts());
    console.log("route", "login");
  },

  register: function() {
    this.reset();
    this._main = new Register(this._opts());
  },

  song: function(id) {
    this.reset();
    this._main = new Song(this._opts({
      id: id
    }));
    document.querySelector('#search-input').blur();
  },

  me: function() {
    console.log("route me");
    this.reset();
    this._main = new Me(this._opts());
  },

  transcriptions: function(page) {
    console.log("route", "transcriptions");
    this.reset();
    this._main = new Transcriptions(this._opts());
  }
});