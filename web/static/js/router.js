var _ = require('underscore');
var bb = require('backbone');

var Register = require('./register');
var Login = require('./login');
var Transcriptions = require('./transcriptions');
var Me = require('./me');
var Song = require('./song');
var About = require('./about');

module.exports = bb.Router.extend({
  routes: {
    '': 'index',
    'login': 'login',
    'logout': 'logout',
    'register': 'register',
    'song/:uid': 'song',
    'song/:uid/region/:id': 'song',
    'me': 'me',
    'about': 'about',
    'transcriptions/:page': 'transcriptions'

  },

  initialize: function(opts) {
    this._options = opts;
    this.dispatcher = opts.dispatcher;
  },

  _opts: function(o) {
    return _.extend(o || {}, this._options);
  },

  start: function() {
    if (this._isStarted) return;
    bb.history.start();
    this._isStarted = true;
  },

  index: function() {
    this.reset();
  },

  reset: function() {
    this.dispatcher.trigger('error:dismiss');
    if (this._main) this._main.destroy();
  },

  login: function() {
    this.reset();
    this._main = new Login(this._opts());
  },

  logout: function() {
    if (this.api && this.api.session) {
      this.api.session.destroy();
      delete this.api.session;
    }
    localStorage.clear();
    this.navigate('#', {
      trigger: true
    });
  },

  register: function() {
    this.reset();
    this._main = new Register(this._opts());
  },

  song: function(songId, regionId) {
    this.reset();
    this._main = new Song(this._opts({
      songId: songId,
      regionId: regionId
    }));
    document.querySelector('#search-input').blur();
  },

  me: function() {
    this.reset();
    this._main = new Me(this._opts());
  },

  about: function() {
    this.reset();
    this._main = new About(this._opts());
  },

  transcriptions: function(page) {
    this.reset();
    this._main = new Transcriptions(this._opts());
  }
});