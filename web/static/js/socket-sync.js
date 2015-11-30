var _ = require('underscore');
module.exports = {

  sync: function(method, model, options) {
    var resource = model.name;
    if(_.isArray(model.models)) {
      method = 'list';
    }
    var name = method + ':' + resource;
    console.log("API", name, this.payloadFor(method));
    this._api.push(name, this.payloadFor(method))
      .receive("ok", function(payload) {
        payload = this.parse(payload);
        this.set(payload)
        this.trigger('sync', this);
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

}