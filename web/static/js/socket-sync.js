var _ = require('underscore');
module.exports = {

  sync: function(method, model, options) {
    var resource = model.name;
    if(_.isArray(model.models)) {
      method = 'list';
    }

    var name = method + ':' + resource;
    var requestPayload = this.payloadFor(method);
    this._dispatcher.trigger('history:' + name, this);

    if(method==='destroy') {
      debugger;
    }
    console.log("API", name, this.payloadFor(method));
    this._api.push(name, requestPayload)
      .receive("ok", function(payload) {
        payload = this.parse(payload);
        console.log("sync success", name, payload)
        this.set(payload);
        this.trigger('sync', this);
        this._onSync();
        this._dispatcher.trigger(name + ':success', this);
      }.bind(this))
      .receive("error", function(payload) {
        console.log("sync error", name, payload)
        this.trigger('error', payload);
        this._onError();
        this._dispatcher.trigger(name + ':error', payload, this);
      }.bind(this));
    return this;
  },

  _onSync: function() {},
  _onError: function() {},

};