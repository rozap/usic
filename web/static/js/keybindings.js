var keyCodes = require('./keycodes');
var $ = require('jquery');
var _ = require('underscore');

function KeyBindings(dispatcher) {
  this._dispatcher = dispatcher;
  this._bind();
  dispatcher.on('all', function() {
    console.log("emit event", Array.prototype.slice.call(arguments));
  });
}

KeyBindings.prototype = {
  _bind: function() {
    $('body').unbind('keydown')
      .bind('keydown', this._onKey.bind(this));
    $('body').unbind('keyup')
      .bind('keyup', this._onKey.bind(this));
  },

  _onKey: function(e) {
    var dispatchEvent = this._getEvent(e);
    if (dispatchEvent) {
      this._dispatcher.trigger('input:' + dispatchEvent, e);
    }
  },

  _getEvent: function(e) {
    return _.reduce(keyCodes, function(acc, spec, eventName) {
      // console.log(e.type, e.keyCode, '-->', spec.type, spec.code)
      if (e.shiftKey === (!!spec.shift) &&
        e.type === spec.type &&
        e.keyCode === spec.code) {
        return eventName;
      }
      return acc;
    }, false);
  }
};


module.exports = KeyBindings;