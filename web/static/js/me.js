var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');

var User = require('./models/user');
var Session = require('./models/session');
var Transcriptions = require('./transcriptions');
var MeTemplate = require('./templates/me.html');

module.exports = View.extend({
  el: '#main',
  template: _.template(MeTemplate),

  renderTo: ['session', 'user'],

  events: {
    'click .edit-display-name': 'onEditDisplayName',
    'click .edit-email': 'onEditEmail'
  },

  init: function(opts) {
    this.session = new Session({}, opts);
    this.user = new User({}, opts);

    this.listenTo(this.session, 'sync change', this.r);
    this.listenTo(this.session, 'sync', this.onSessionSync);
    this.listenTo(this.session, 'error', this.onSessionErr);
    this.listenTo(this.user, 'sync', this.onUserSync);
    this.listenTo(this.dispatcher, 'input:onConfirm', this.onConfirm);

    this.session.fetch();
    this.render();

  },

  onSessionErr: function() {
    window.location.hash = '#';
  },

  onSessionSync: function() {
    var opts = this._opts;

    this.user.set(this.session.get('user'));

    opts.title = 'my_transcriptions';
    opts.el = '#my-transcriptions';
    opts.collectionState = {
      where: {
        user_id: this.session.get('user').id
      }
    };
    this.render();
    this.addSubview('transcriptions', Transcriptions, opts);
  },

  onUserSync: function() {
    this.setState({});
  },

  _edit: function(name) {
    name = 'isEditing' + name;
    var value = !this._state[name];
    var state = {};
    state[name] = value;
    this.updateState(state);
  },

  onEditDisplayName: function() {
    this._edit('DisplayName');
  },

  onEditEmail: function() {
    this._edit('Email');
  },

  isEditing: function() {
    return this._state.isEditingDisplayName ||
      this._state.isEditingEmail;
  },

  onConfirm: function() {
    if (!this.user.get('id')) return;
    if (!this.isEditing()) return;
    this.user.set(this.serializeForm('.pure-form')).save();
  }


});