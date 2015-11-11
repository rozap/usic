var bb = require('backbone');

module.exports = bb.Model.extend({
  initialize: function(attrs, opts) {
    bb.Model.prototype.initialize.call(this, attrs, opts);
    this._api = opts.api;
    this._dispatcher = opts.dispatcher;
    if (!this._api) throw new Error("Model needs api channel");
  },

  sync: function(method, model, options) {
    var name = method + ':' + model.name;
    console.log("API", name, this.toJSON());
    this._api.push(name, this.toJSON())
      .receive("ok", function(payload) {
        this.set(payload).trigger('sync', this);
        this._onSync();
        this._dispatcher.trigger(name + ':success', this);
      }.bind(this))
      .receive("error", function(payload) {
        this.trigger('error', payload);
        this._onError();
        this._dispatcher.trigger(name + ':error', payload, this);
      }.bind(this));
    return this;
  },

  _onSync: function() {},
  _onError: function() {},

});