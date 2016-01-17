var keyCodes = require('./keycodes');
var $ = require('jquery');
var _ = require('underscore');

function KeyBindings(dispatcher) {
  this._dispatcher = dispatcher;
  this._bind();

  dispatcher.on('input:unbind', this._pause.bind(this));
  dispatcher.on('input:bind', this._resume.bind(this));

}

KeyBindings.prototype = {
  _pause: function() {
    this._isPaused = true;
  },
  _resume: function() {
    this._isPaused = false;
  },

  _unbind: function() {
    return $('body').unbind('keydown').unbind('keyup');
  },

  _bind: function() {
    this._unbind()
      .bind('keydown', this._onKey.bind(this))
      .bind('keyup', this._onKey.bind(this));
  },

  _onTextFocus: function(e) {
    console.log("text focus");
  },

  _onKey: function(e) {
    var dispatchEvent = this._getEvent(e);
    if (dispatchEvent && !e.isDefaultPrevented()) {
      this._dispatcher.trigger('input:' + dispatchEvent, e);
    }
  },

  _getEvent: function(e) {
    return _.reduce(keyCodes, function(acc, spec, eventName) {
      // console.log(e.type, e.keyCode, '-->', spec.type, spec.code)
      if (
        e.shiftKey === (!!spec.shift) &&
        e.ctrlKey === (!!spec.ctrlKey) &&
        e.type === spec.type &&
        e.keyCode === spec.code) {

        if(!spec.important && this._isPaused) {
          return acc;
        }

        return eventName;
      }
      return acc;
    }.bind(this), false);
  }
};


module.exports = KeyBindings;