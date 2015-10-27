var _ = require('underscore');
var View = require('./view');
var $ = require('jquery');

var RegionsTemplate = require('./templates/regions.html');
var RegionTemplate = require('./templates/region.html');

var Region = View.extend({
  tagName: 'li',
  template: _.template(RegionTemplate),

  attributes:{
    'class': 'region'
  },

  init: function(opts) {
    this._region = opts.region;
    this._state.pxPerSec = opts.pxPerSec;
    this._state.duration = opts.duration;
    this.listenTo(this._parent, 'zoom', this.onZoom);
  },

  onZoom:function(pps, duration) {
    this.updateState({
      pxPerSec: pps,
      duration: duration
    });
  },

  getAttributes: function() {
    var width = this._width();
    return {
      'style' : this.buildStyle(['width', 'left'])
    };
  },

  _width: function() {
    var seconds = (this._region.end - this._region.start);
    return parseInt(seconds * this._state.pxPerSec) + 'px';
  },

  _left:function() {
    return parseInt(this._region.start * this._state.pxPerSec) + 'px';
  },

  getId:function() {
    return this._region.id;
  },


});


var Regions = View.extend({
  template: _.template(RegionsTemplate),
  el: '#view-regions',

  events : {
    'scroll' : 'onScroll'
  },

  init: function(opts) {
    this._wavesurfer = opts.wavesurfer;
    this._bindEvents();
    this.render();
  },

  _bindEvents: function() {
    this._wavesurfer.on('region-update-end', this.onUpdated.bind(this));
    this._wavesurfer.on('region-removed', this.onRemoved.bind(this));
    this._wavesurfer.on('region-click', this.onSelected.bind(this));
    this.listenTo(this._parent, 'pan', this.panTo);
    this.listenTo(this._parent, 'zoom', this.zoomTo);

  },

  onUpdated: function(region) {
    region.loop = true;
    this._wavesurfer.skip(region.start - region.end);

    var existing = this._findRegionView(region);
    if (!existing) {

      this.appendView('regions', Region, {
        region: region,
        pxPerSec: this._getPxPerSec(),
        duration: this._getDuration()
      });
    }

    this.render();
  },

  //TODO: urgh
  _getPxPerSec:function() {
    return this._wavesurfer.params.minPxPerSec;
  },
  //TODO: urgh
  _getDuration:function() {
    return this._wavesurfer.getDuration();
  },

  getState:function() {
    return _.extend({
      width: Math.round(this._getPxPerSec() * this._getDuration()) + 'px',
    }, this._state);
  },

  onRemoved: function() {

  },

  onSelected: function() {

  },

  onScroll:function(e) {
    this.trigger('scroll', e.target.scrollLeft);
  },

  panTo:function(p) {
    this.$el.scrollLeft(p);
  },

  zoomTo:function(pps, duration) {
    this.trigger('zoom', pps, duration);
    this.render();
  },


  onRendered: function() {
    var $list = this._getListEl();
    this._regionViews().forEach(function(view) {
      $list.append(view.render().el);
    }.bind(this));
  },

  _getListEl:function() {
    return this.$el.find('#region-list');
  },

  _findRegionView: function(region) {
    return _.find(this.getSubview('regions'), function(regionView) {
      return regionView.getId() === region.id;
    });
  },

  _regionViews: function() {
    return this._subviews.regions || [];
  },

  destroy: function() {

  }


});


module.exports = Regions;