var _ = require('underscore');
var bb = require('backbone');
var socketSync = require('../socket-sync');

module.exports = bb.Model.extend(_.extend({

  initialize: function(attrs, opts) {
    bb.Model.prototype.initialize.call(this, attrs, opts);
    this._api = opts.api;
    this._dispatcher = opts.dispatcher;
    if (!this._api) throw new Error("Model needs api channel");
  },

  payloadFor: function(method) {
    return this.toJSON();
  }
}, socketSync));