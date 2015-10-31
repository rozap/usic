var _ = require('underscore');
var View = require('./view');
var $ = require('jquery');

var RegionView = require('./region');
var ClicksView = require('./clicks');
var RegionsTemplate = require('./templates/regions.html');

module.exports = View.extend({
  template: _.template(RegionsTemplate),
  el: '#view-regions',

  events: {
    'scroll': 'onScroll'
  },

  init: function(opts) {
    this.model = opts.model;
    this._wavesurfer = opts.wavesurfer;
    this._bindEvents();
    this.render();

    var clicksView = this.addSubview('clicks', ClicksView, {
      model: opts.model,
      wavesurfer: this._wavesurfer
    });
  },

  _bindEvents: function() {
    this._wavesurfer.on('region-update-end', this.onCreated.bind(this));
    this._wavesurfer.on('scroll', this.onScroll.bind(this));
    this.listenTo(this._parent, 'pan', this.panTo);
    this.listenTo(this._parent, 'zoom', this.zoomTo);
  },

  onDeselect:function(view){
    (this.getSubview('regions') || []).forEach(function(region) {
      if(region.cid !== view.cid) region.onDeselect();
    });
  },

  onCloned:function(region) {
    var bounds = region.getBounds();
    var region = this._wavesurfer.addRegion({
      start: bounds.end,
      end: bounds.end + (bounds.end - bounds.start)
    });
    //hack because update-end event isn't fired
    this.onCreated(region);
  },

  onCreated: function(region) {
    var existing = this._findRegionView(region);
    if (existing) return;
    var view = this.appendView('regions', RegionView, {
      region: region,
      song: this.model,
      defaultName: this._buildDefaultName(),
      pxPerSec: this._getPxPerSec(),
      duration: this._getDuration(),
    });
    this.listenTo(view, 'selected', this.onDeselect);
    this.listenTo(view, 'cloned', this.onCloned);
    view.onSelect();
    this.render();
  },

  _buildDefaultName: function() {
    var count = (this.getSubview('regions') || []).length;
    var wrap = Math.floor(count / 26);
    var index = wrap === 0 ? '' : wrap;
    return String.fromCharCode(65 + (count % 26) + index);
  },

  //TODO: urgh
  _getPxPerSec: function() {
    return this._wavesurfer.params.minPxPerSec;
  },
  //TODO: urgh
  _getDuration: function() {
    return this._wavesurfer.getDuration();
  },

  getState: function() {
    return _.extend({
      width: Math.round(this._getPxPerSec() * this._getDuration()) + 'px',
    }, this._state);
  },

  onScroll: function(e) {
    this.trigger('scroll', e.target.scrollLeft);
  },

  panTo: function(p) {
    this.$el.scrollLeft(p);
  },

  zoomTo: function(pps, duration) {
    this.trigger('zoom', pps, duration);
    this.render();
  },


  onRendered: function() {
    var $list = this._getListEl();
    this._regionViews().forEach(function(view) {
      view.undelegateEvents();
      $list.append(view.render().el);
      view.delegateEvents();
    }.bind(this));
  },

  _getListEl: function() {
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
