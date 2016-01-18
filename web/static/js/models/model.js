var _ = require('underscore');
var bb = require('backbone');
var socketSync = require('../socket-sync');

module.exports = bb.Model.extend(_.extend({

  initialize: function(attrs, opts) {
    bb.Model.prototype.initialize.call(this, attrs, opts);
    this.opts(opts);
    this.listenTo(this._dispatcher, 'update:' + this.name, this._onUpdate);

    if (!this._api) throw new Error("Model needs api channel");
  },

  opts: function(opts) {
    if (opts) {
      console.log("OPTS ARE NOW", opts);
      this._api = opts.api;
      this._dispatcher = opts.dispatcher;
      this._opts = opts;
    }
    return this._opts;
  },

  _onUpdate: function(payload) {
    if (payload.id === this.get('id')) this.set(payload);
  },

  payloadFor: function(method) {
    return this.toJSON();
  },

  clone: function(attrs) {
     return new this.constructor(this.attributes, this.opts()).unset(this.idAttribute);
  }
}, socketSync));