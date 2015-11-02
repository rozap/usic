var bb = require('backbone');

module.exports = bb.Model.extend({
  initialize:function(attrs, opts) {
    bb.Model.prototype.initialize.call(this, attrs, opts);
    this._api = opts.api;
    this._api.on('chan_reply_create:' + this.name, this._onCreate);
    if(!this._api) throw new Error("Model needs api channel");
  },

  _onCreate:function() {
    console.log("ON CREATE");
  },

  sync: function(method, model, options) {
    console.log(method, model, options);
    var name = method + ':' + model.name;
    this._api.push(name, this.toJSON())
    .receive("ok", function(payload) {
      this.clear({silent: true}).set(payload).trigger('sync', this);
    }.bind(this))
    .receive("error", function(payload) {
      this.trigger('error', payload);
    }.bind(this));
    return this;
  }
});