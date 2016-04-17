var $ = require('jquery');
var bb = require('backbone');
var t = require('./translate').t;
var _ = require('underscore');

var Wave = require('./wave');
var View = require('./view');
var Song = require('./models/song');
var SongTemplate = require('./templates/song.html');
var SongTitle = require('./song-title');
var keyCodes = require('./keycodes');

var ControlsView = require('./controls');
var WaveView = require('./wave');
var RegionView = require('./regions');
var ClicksView = require('./clicks');

var History = require('./history');

module.exports = View.extend({
  el: '#main',
  template: _.template(SongTemplate),
  _audio: {},
  _zoomDelta: 2,
  _panDelta: 30,
  _maxPps: 66, //TODO: why does it go to shit at 106
  _minPps: 2,
  _pan: 0,

  events: {
    'mousewheel .interactive': 'onWheelWaveform',
    'keydown': 'onKeyDown'
  },

  init: function(opts) {
    this.listenTo(this, 'state.update.songId', this._onSongChanged);
    this.listenTo(this, 'state.update.regionId', this._onRegionChanged);
    window.song = this;
  },

  _onSongChanged: function(oldId, newId) {
    if (!oldId || (oldId !== newId)) {
      this.model = new Song({
        id: newId
      }, this._opts);
      this.listenToOnce(this.model, 'sync', this._loadSong);
      this.listenTo(this.model, 'error', this._onError);
      this._history = new History(this.dispatcher);
      this.model.fetch();
    }
  },

  _onRegionChanged:function(_oldRegion, newRegion) {
    console.log(_oldRegion, "-->", newRegion)
    this._state.centerOnRegionId = newRegion;
  },

  _onError: function(err) {
    this.dispatcher.trigger('error:new', err);
  },

  _loadSong: function() {
    this.render();

    this.addSubview('song-title', SongTitle, {
      model: this.model
    });

    var loc = this.model.get('location');
    var req = new XMLHttpRequest();
    req.open('GET', loc);
    req.responseType = 'arraybuffer';
    req.onload = _.partial(this._onSongLoaded, req).bind(this);
    req.send();
  },

  _onSongLoaded: function(req) {
    this._audio.context = new(AudioContext || webkitAudioContext)(); //jshint ignore:line
    this._audio.context.decodeAudioData(req.response,
      _.once(this._onBufferLoaded).bind(this),
      _.once(this._onBufferError).bind(this)
    );
  },

  _onBufferLoaded: function(buf) {
    this._audio.buffer = buf;

    var waveView = this.addSubview('wave', WaveView, {
      buf: buf
    });
    var wavesurfer = waveView.wv();
    this._audio.wavesurfer = wavesurfer;

    var regionsView = this.addSubview('regions', RegionView, {
      wavesurfer: wavesurfer,
      model: this.model,
      dispatcher: this.dispatcher,
      api: this.api,
      centerOn: this._state.centerOnRegionId
    });
    this.listenTo(regionsView, 'scroll', this.panTo);
    this.addSubview('controls', ControlsView, {
      audio: this._audio,
      model: this.model
    });
  },

  _onBufferError: function(err) {
    this.setState({
      state: 'error',
      error: err
    });
  },


  onWheelWaveform: function(e) {
    e.preventDefault();
    var up = e.originalEvent.wheelDelta > 0;
    if (e.shiftKey) {
      var oldPps = this.pxPerSec();
      up ? this.zoomIn() : this.zoomOut(); //jshint ignore:line
      var newPan = Math.floor(this._pan * (this.pxPerSec() / oldPps));
      this.panTo(newPan);
      return;
    }
    return up ? this.panLeft() : this.panRight();
  },

  panRight: function() {
    var p = Math.min(
      this._pan + this._panDelta,
      this.getSubview('wave').getWidth()
    );
    this.panTo(p);
  },

  panLeft: function() {
    var p = Math.max(
      this._pan - this._panDelta,
      0
    );
    this.panTo(p);
  },

  panTo: function(p) {
    this._pan = p;
    this.trigger('pan', p);
    return this;
  },

  pxPerSec: function() {
    return this._audio.wavesurfer.params.minPxPerSec;
  },

  zoomIn: function() {
    var pps = this.pxPerSec() + this._zoomDelta;
    if (pps > this._maxPps) return;
    this.zoomTo(pps);
  },

  zoomTo: function(pps) {
    pps = Math.max(pps, this._minPps);
    pps = Math.min(pps, this._maxPps);
    this.trigger('zoom', pps, this._audio.wavesurfer.getDuration());
    this._audio.wavesurfer.fireEvent('zoom');
    return this;
  },

  zoomOut: function() {
    var duration = this._audio.wavesurfer.getDuration();
    if (duration <= 0) return;

    var pps = this.pxPerSec() - this._zoomDelta;
    var minPps = this.$el.width() / duration;
    if (pps < minPps) pps = minPps;
    this.zoomTo(pps);
  },

  viewportWidth: function() {
    return this.el.clientWidth;
  },

  destroy: function() {
    if (this._audio.wavesurfer) this._audio.wavesurfer.destroy();
    if (this._history) this._history.destroy();
    this._destroy();
  }
});