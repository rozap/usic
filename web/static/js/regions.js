var _ = require('underscore');
var View = require('./view');
var $ = require('jquery');

var Regions = require('./collections/regions');
var RegionModel = require('./models/region');
var RegionView = require('./region');
var ClicksView = require('./clicks');
var RegionsTemplate = require('./templates/regions.html');

module.exports = View.extend({
  template: _.template(RegionsTemplate),
  el: '#view-regions',

  events: {
    'scroll': 'onScroll'
  },

  _minRegionSize: 0.25,

  init: function(opts) {
    this._wavesurfer = opts.wavesurfer;
    this.regions = new Regions(opts.model.get('regions'), {
      song: opts.model,
      api: opts.api,
      dispatcher: opts.dispatcher
    });
    this._bindEvents();

    this.listenTo(this.regions, 'error', this.onRegionsError);
    this.listenTo(this.regions, 'add', this.r);

    this.render();

    this._addWavesurferRegions();
    this._onCenterRegionChanged(null, opts.centerOn);

    this.addSubview('clicks', ClicksView, {
      model: this.model,
      wavesurfer: this._wavesurfer
    });
  },

  _bindEvents: function() {
    this._wavesurfer.on('region-update-end', this.onWaveRegionUpdated.bind(this));
    this._wavesurfer.on('scroll', this.onScroll.bind(this));
    this.listenTo(this._parent, 'pan', this.panTo);
    this.listenTo(this._parent, 'zoom', this.zoomTo);
    this.listenTo(this._parent, 'state.update.regionId', this._onCenterRegionChanged);
    this.listenTo(this.dispatcher, 'input:onEnableZoomTool', this.onEnableZoomTool);
    this.listenTo(this.dispatcher, 'input:onDisableZoomTool', this.onDisableZoomTool);

    this.listenTo(this.regions, 'change', function( ){
      this.model.set('regions', this.regions.toJSON())
    });
  },

  onDeselect: function(view) {
    (this.getSubview('regions') || []).forEach(function(region) {
      if (region.cid !== view.cid) region.onDeselect();
    });
  },

  onEnableZoomTool: function() {
    $('body').css({
      cursor: 'zoom-in'
    });
    this._state.zoomSelection = true;
    this.regions.each(function(region) {
      region.disableInteraction();
    });
  },

  onDisableZoomTool: function() {
    $('body').css({
      cursor: 'pointer'
    });
    this._state.zoomSelection = false;
    this.regions.each(function(region) {
      region.enableInteraction();
    });

  },

  onCloned: function(region) {
    var bounds = region.getBounds();
    var r = this._wavesurfer.addRegion({
      start: bounds.end,
      end: bounds.end + (bounds.end - bounds.start)
    });
    //hack because update-end event isn't fired
    this.onWaveRegionUpdated(r);
  },

  onRegionsError: function(err) {
    this.dispatcher.trigger('error:new', err);
  },

  _regionsSansViews: function() {
    var truth = {};
    (this.getSubview('regions') || []).forEach(function(regionView) {
      truth[regionView.modelId()] = true;
    });
    return this.regions.filter(function(region) {
      return !truth[region.get('id')];
    });
  },

  _addWavesurferRegions: function() {
    this.regions.each(function(model) {
      var waveRegion = this._wavesurfer.addRegion({
        start: model.get('start'),
        end: model.get('end'),
        loop: model.get('loop')
      });
      model.addUnderlying(waveRegion);

    }.bind(this));
    this.render();
  },

  onWaveRegionUpdated: function(waveRegion) {
    if (this._state.zoomSelection) {
      this.onDisableZoomTool();
      this._zoomSelection(waveRegion.start, waveRegion.end);
      waveRegion.remove();
    } else {
      var existing = this._findRegionView(waveRegion);
      if (existing) {
        existing.onSelect();
        return;
      }

      if(waveRegion.end - waveRegion.start < this._minRegionSize) {
        return waveRegion.remove();
      }

      var model = new RegionModel({
        name: this._buildDefaultName(),
        song_id: this.model.get('id')
      }, {
        api: this.api,
        dispatcher: this.dispatcher,
        song: this.model
      });
      model.addUnderlying(waveRegion).save();
    }
    // this.regions.add(model);
  },

  _buildDefaultName: function() {
    var count = (this.getSubview('regions') || []).length;
    var wrap = Math.floor(count / 26);
    var index = wrap === 0 ? '' : wrap;
    return String.fromCharCode(65 + (count % 26) + index);
  },

  _onCenterRegionChanged: function(_oldRegion, centerOn) {
    if (centerOn) {
      var centerId = parseInt(centerOn);
      var region = this.regions.get(centerId);
      if (!region) return;

      this._zoomSelection(region.get('start'), region.get('end'));
    }
  },

  _zoomSelection: function(start, end) {
    var pad = 80;
    var duration = end - start;
    var pps = (this._parent.viewportWidth() - pad) / duration;

    this._parent
      .zoomTo(pps)
      .panTo((start * this._parent.pxPerSec()) - (pad / 2));
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

  zoomTo: function(pps) {
    this.trigger('zoom', pps, this._getDuration());
    this.render();
  },

  onRendered: function() {
    this._regionsSansViews().map(function(model) {
      var view = this.appendView('regions', RegionView, {
        model: model,
        song: this.model,
        api: this.api,
        dispatcher: this.dispatcher,
        pxPerSec: this._getPxPerSec(),
        duration: this._getDuration()
      });

      this.listenTo(view, 'selected', this.onDeselect);
      this.listenTo(view, 'cloned', this.onCloned);
    }.bind(this));

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

  _findRegionView: function(waveRegion) {
    return _.find(this.getSubview('regions'), function(regionView) {
      return regionView.waveId() === waveRegion.id;
    });
  },

  _regionViews: function() {
    return this._subviews.regions || [];
  }
});