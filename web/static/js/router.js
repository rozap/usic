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

  set: function(name, Cls, opts) {
    if (this._viewName !== name) {
      this.reset();
      this._main = new Cls(opts || this._opts());
    }
    this._viewName = name;
    return this._main;
  },

  login: function() {
    this.set('login', Login);
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
    this.set('register', Register);
  },

  song: function(songId, regionId) {
    this.set('song', Song)
      .updateState({
        songId: songId
      })
      .updateState({
        regionId: regionId
      });
    document.querySelector('#search-input').blur();
  },

  me: function() {
    this.set('me', Me);
  },

  about: function() {
    this.set('about', About);
  },

  transcriptions: function(page) {
    this.set('transcriptions', Transcriptions);
  }
});