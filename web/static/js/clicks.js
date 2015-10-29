var _ = require('underscore');
var View = require('./view');
var $ = require('jquery');

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
    this.listenTo(this.dispatcher, 'input:onBeatCreated', this.onBeatCreated);
  },

  getState:function() {
    return {
      scale: this._wavesurfer.params.minPxPerSec
    };
  },

  onBeatCreated: function() {
    var clicks = this.model.get('clicks');
    this.model.set('clicks', clicks.concat([this._wavesurfer.getCurrentTime()]));
  }
});