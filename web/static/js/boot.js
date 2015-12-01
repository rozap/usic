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
var Session = require('./models/session');


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
var router = new Router(opts);
opts.router = router;

function getSessionToken() {
  try {
    //TODO: fix this duplication with the model
    var token = JSON.parse(localStorage.usic).token;
    if(!token) return 'session';
    return "session:" + token;
  } catch(e) {
    return "session";
  }
}

function hasSession(token) {
  return token !== "session";
}

new KeyBindings(dispatcher);

socket.onOpen(function() {
  dispatcher.trigger('error:dismiss');

  console.log("Joining..");
  var token = getSessionToken();
  var api = socket.channel(token, {});
  opts.api = api;

  opts.api.onMessage = function(event, payload) {
    dispatcher.trigger(event, payload);
  }

  new ErrorView(opts);
  new LoaderView(opts);

  api.join()
    .receive('ok', function(resp) {
      new MetaView(opts);
      router.start();

      if(hasSession(token)) {
        var session = new Session({}, opts);
        session.fetch();
      }

    })
    .receive('error', function(reson) {
      dispatcher.trigger('error:new', 'api_channel_error', {fatal : false});
    });


});
socket.onError(function() {
  dispatcher.trigger('error:new', 'socket_error', {fatal : false});
});
socket.connect();