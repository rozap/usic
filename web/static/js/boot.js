var phx = require('./phoenix');
var bb = require('backbone');
var _ = require('underscore');
var uuid = require('uuid');
var View = require('./view');

var KeyBindings = require('./keybindings');
var LoaderView = require('./loader');
var MetaView = require('./meta');
var ErrorView = require('./error');
var Router = require('./router');

var dispatcher = _.clone(bb.Events);

var socket = new phx.Socket("/socket", {
  params: {
    userToken: "someToken"
  }
});

var opts = {
  socket: socket,
  dispatcher: dispatcher
};

function getSessionToken() {
  try {
    //TODO: fix this duplication with the model
    var sesh = JSON.parse(localStorage['usic']);
    return "session:" + sesh.token;
  } catch(e) {
    return "session";
  }
}

var router = new Router(opts);
new KeyBindings(dispatcher);

socket.onOpen(function() {
  dispatcher.trigger('error:dismiss');

  var api = socket.channel(getSessionToken(), {});
  window.a = api;
  opts.api = api;

  new ErrorView(opts);
  new LoaderView(opts);

  api.join()
    .receive('ok', function(resp) {
      new MetaView(opts);
      router.start();
    })
    .receive('error', function(reson) {
      dispatcher.trigger('error:new', 'api_channel_error', {fatal : false});
    });


});
socket.onError(function() {
  dispatcher.trigger('error:new', 'socket_error', {fatal : false});
});
socket.connect();