var _ = require('underscore');
var uuid = require('uuid');
var View = require('./view');
var LoadResult = require('./load-result');


module.exports = View.extend({
  el: "#search",

  events: {
    "keyup input": "_onSearch"
  },

  init: function(opts) {
    this._state = {term: null};
    this._bootstrapChannel(opts);
    this._bootstrapViews(opts);
  },

  _bootstrapViews: function(opts) {
    this.addSubview('result', LoadResult);
  },

  _bootstrapChannel: function(opts) {
    this._channel = opts.socket.channel("song:" + uuid.v4(), {});
    this._channel.join();

    this._channel.onMessage = function(ref, reply) {
      var event = (reply && reply.response && reply.response.event) || ref;
      this.trigger('reply:' + event, reply && reply.response);
    }.bind(this);
  },

  _onSearch: function(e) {
    var term = e.currentTarget.value.replace(/ /g,'');
    if(this._state.term !== term) {
      this._state.term = term;
      this._channel.push("search", {
        term: this._state.term
      });
    }
  }
});