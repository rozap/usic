var _ = require('underscore');
var bb = require('backbone');
var socketSync = require('../socket-sync');

module.exports = bb.Model.extend(_.extend({

  initialize: function(attrs, opts) {
    bb.Model.prototype.initialize.call(this, attrs, opts);
    this.resetHistory();
    this._api = opts.api;
    this._dispatcher = opts.dispatcher;
    this.listenTo(this._dispatcher, 'update:' + this.name, this._onUpdate);
    if (!this._api) throw new Error("Model needs api channel");
  },

  _onUpdate: function(payload) {
    if (payload.id === this.get('id')) this.set(payload);
  },

  payloadFor: function(method) {
    return this.toJSON();
  },

  set: function() {
    var args = Array.prototype.slice.call(arguments);
    var opts = _.last(args) || {}
    if (!opts.untracked && this._behind != null) {
      this._behind.push(this.toJSON());
      this._ahead = [];
    }
    return bb.Model.prototype.set.apply(this, args);
  },

  redo: function() {
    this._behind.push(this.toJSON());
    var state = this._ahead.pop();
    if (!state) return;
    this.set(state, {
      untracked: true
    });
  },

  undo: function() {
    this._ahead.push(this.toJSON())
    var state = this._behind.pop();
    if (!state) return;
    this.set(state, {
      untracked: true
    })
  },

  resetHistory: function() {
    this._ahead = [];
    this._behind = [];
    this._changePointer = 0;
  }
}, socketSync));