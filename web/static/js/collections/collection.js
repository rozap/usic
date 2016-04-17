var _ = require('underscore');
var bb = require('backbone');
var socketSync = require('../socket-sync');

module.exports = bb.Collection.extend(_.extend({
  _pageSize: 8,
  initialize: function(models, opts) {
    bb.Collection.prototype.initialize.call(this, models, opts);

    this._api = opts.api;
    this._dispatcher = opts.dispatcher;
    this._meta = {
      count: Infinity
    };
    this._state = _.extend({
      offset: 0,
      limit: this._pageSize
    }, opts.collectionState);

    if (!this._api) throw new Error("Model needs api channel");

    this.listenTo(this, 'state', this._onStateChange);
  },

  updateState: function(name, value) {
    this._state[name] = value;
    this.trigger('state', this._state);
  },

  getState: function() {
    return this._state;
  },

  _onStateChange: function() {
    this.fetch();
  },

  payloadFor: function(method) {
    return this._state;
  },

  parse: function(payload) {
    this._meta.count = payload.count;
    return payload.items;
  },

  modelOpts: function(opts) {
    return opts;
  },

  _prepareModel: function(attrs, options) {
    if (this._isModel(attrs)) {
      if (!attrs.collection) attrs.collection = this;
      return attrs;
    }
    options = this.modelOpts(options ? _.clone(options) : {});
    options.collection = this;
    options.api = this._api;
    options.dispatcher = this._dispatcher;
    var model = new this.model(attrs, options);
    if (!model.validationError) return model;
    this.trigger('invalid', this, model.validationError, options);
    return false;
  },

  hasNext: function() {
    var page = this.currentPage() + 1;
    return page < this.maxPage();
  },

  hasPrevious: function() {
    return this._state.offset > 0;
  },

  next: function() {
    if (!this.hasNext()) return this;
    this.updateState('offset', this._state.offset + this._pageSize);
  },

  previous: function() {
    if (!this.hasPrevious()) return this;
    this.updateState('offset', this._state.offset - this._pageSize);
  },

  currentPage: function() {
    return Math.floor(this._state.offset / this._pageSize);
  },

  maxPage: function() {
    return Math.ceil(this._meta.count / this._pageSize);
  }

}, socketSync));