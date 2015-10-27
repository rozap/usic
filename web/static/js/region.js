var _ = require('underscore');
var View = require('./view');

var RegionModel = require('./models/region');
var RegionTemplate = require('./templates/region.html');

module.exports = View.extend({
  tagName: 'li',
  template: _.template(RegionTemplate),

  attributes: {
    'class': 'region'
  },

  renderTo: ['model'],

  init: function(opts) {
    this.model = new RegionModel(opts.region, opts.defaultName);
    this._state.pxPerSec = opts.pxPerSec;
    this._state.duration = opts.duration;
    this.listenTo(this._parent, 'zoom', this.onZoom);
    this.listenTo(this.model, 'change', this.r);
  },

  onZoom: function(pps, duration) {
    this.updateState({
      pxPerSec: pps,
      duration: duration
    });
  },

  getAttributes: function() {
    var width = this._width();
    return {
      'style': this.buildStyle(['width', 'left'])
    };
  },

  _width: function() {
    var seconds = (this.model.get('end') - this.model.get('start'));
    return parseInt(seconds * this._state.pxPerSec) + 'px';
  },

  _left: function() {
    return parseInt(this.model.get('start') * this._state.pxPerSec) + 'px';
  },

  getId: function() {
    return this.model.get('id');
  }
});