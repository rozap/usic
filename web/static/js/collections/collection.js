var _ = require('underscore');
var bb = require('backbone');
var socketSync = require('../socket-sync');

module.exports = bb.Collection.extend(_.extend({
  _pageSize: 8,
  initialize: function(models, opts) {
    bb.Collection.prototype.initialize.call(this, models, opts);

    this._api = opts.api;
    this._dispatcher = opts.dispatcher;
    this._state = {
      offset: 0,
      limit: this._pageSize
    };

    if (!this._api) throw new Error("Model needs api channel");

    this.listenTo(this, 'state', this._onStateChange);
  },

  updateState: function(name, value) {
    this._state[name] = value;
    this.trigger('state', this._state);
  },

  _onStateChange:function() {
    this.fetch();
  },

  payloadFor:function(method) {
    console.log("fetch collection", this._state)
    return this._state;
  },

  _prepareModel: function(attrs, options) {
    if (this._isModel(attrs)) {
      if (!attrs.collection) attrs.collection = this;
      return attrs;
    }
    options = options ? _.clone(options) : {};
    options.collection = this;
    options.api = this._api;
    options.dispatcher = this._dispatcher;
    var model = new this.model(attrs, options);
    if (!model.validationError) return model;
    this.trigger('invalid', this, model.validationError, options);
    return false;
  },


  next: function() {
    this.updateState('offset', this._state.offset + this._pageSize);
  },

  previous: function() {
    this.updateState('offset', Math.min(0, this._state.offset - this._pageSize));
  }

}, socketSync));