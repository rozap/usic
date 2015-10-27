var _ = require('underscore');
var View = require('./view');
var $ = require('jquery');

var keyCodes = require('./keycodes');
var ClicksTemplate = require('./templates/clicks.html');


module.exports = View.extend({
  template: _.template(ClicksTemplate),
  el: '#view-clicks',

  renderTo: ['model'],

  init: function(opts) {
    this._wavesurfer = opts.wavesurfer;
    this.model = opts.model;
    this.listenTo(this.model, 'change:clicks', this.r);
    this.render();
    $('body').unbind('keydown').bind('keydown', this.onKeyDown.bind(this));
  },

  getState:function() {
    return {
      scale: this._wavesurfer.params.minPxPerSec
    }
  },

  onKeyDown: function(e) {
    var fn = this[keyCodes[e.keyCode]];
    if (fn) fn.call(this, e);
  },

  onBeatCreated: function() {
    var clicks = this.model.get('clicks');
    this.model.set('clicks', clicks.concat([this._wavesurfer.getCurrentTime()]));

  }
});