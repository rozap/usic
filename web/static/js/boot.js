var phx = require('./phoenix');
var $ = require('jquery');
var bb = require('backbone');
var _ = require('underscore');
var uuid = require('uuid');

var View = require('./view');
var Song = require('./song');
var LoadResultTemplate = require('./templates/loader.html');


var LoadResult = View.extend({
  el: '#search-result',
  template: _.template(LoadResultTemplate),

  init: function(opts) {
    this.stateChange(opts._parent, 'reply:search', this._update);
  },

  _update: function(state) {
    if(this._song) this._song.destroy();
    if(state.state === 'success') {
      this._songView = new Song({
        result: state
      });

      $('#search-input').blur();
    }
    return state;
  },

});

var Loader = View.extend({
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
    this._channel = opts.socket.channel(
      "song:" + uuid.v4(), {
        token: "sketchy"
      }
    );
    this._channel.join();

    this._channel.onMessage = function(ref, reply) {
      var event = (reply && reply.response && reply.response.event) || ref;
      this.trigger('reply:' + event, reply && reply.response);
    }.bind(this);
  },

  _onSearch: function(e) {
    var term = $(e.target).val().replace(/ /g,'');
    if(this._state.term !== term) {
      this._state.term = term;
      this._channel.push("search", {
        term: this._state.term
      });
    }
  }
});


var socket = new phx.Socket("/socket", {
  params: {
    userToken: "someToken"
  }
});
socket.onOpen(function() {
  var loader = new Loader({
    socket: socket
  });
});
socket.connect();