var $ = require('jquery');
var bb = require('backbone');
var t = require('./translate').t;
var _ = require('underscore');

var Wave = require('./wave');
var View = require('./view');
var SongTemplate = require('./templates/song.html');
var keyCodes = require('./keycodes');

var SongModel = require('./models/song');
var ControlsView = require('./controls');
var WaveView = require('./wave');
var RegionView = require('./regions');
var ClicksView = require('./clicks');

module.exports = View.extend({
  el: '#song',
  template: _.template(SongTemplate),
  _audio: {},
  _zoomDelta: 2,
  _panDelta: 30,
  _maxPps: 106, //TODO: why does it go to shit at 106
  _minPps: 2,
  _pan: 0,

  events: {
    'mousewheel .interactive': 'onWheelWaveform',
    'keydown' : 'onKeyDown'
  },


  init: function(opts) {
    this.updateState(opts.result);
    this.model = new SongModel();
    this._state = {};
  },

  _loadSong: function() {
    var req = new XMLHttpRequest();
    req.open('GET', this.getState().location);
    req.responseType = 'arraybuffer';
    req.onload = _.partial(this._onSongLoaded, req).bind(this);
    req.send();
  },

  _onSongLoaded: function(req) {
    this._audio.context = new(AudioContext || webkitAudioContext)(); //jshint ignore:line
    this._audio.context.decodeAudioData(req.response,
      this._onBufferLoaded.bind(this),
      this._onBufferError.bind(this)
    );
  },

  _onBufferLoaded: function(buf) {
    this._audio.buffer = buf;

    var waveView = this.addSubview('wave', WaveView, {
      buf: buf
    });
    var wavesurfer = waveView.wv();

    var regionsView = this.addSubview('regions', RegionView, {
      wavesurfer: wavesurfer,
      model: this.model
    });
    this.listenTo(regionsView, 'scroll', this.panTo);

    this._audio.wavesurfer = wavesurfer;
    this.addSubview('controls', ControlsView, {
      audio: this._audio
    })
  },

  _onBufferError: function(err) {
    console.warn("Failed to load", err);
    this.setState({
      state: 'error',
      error: err
    });
  },

  onWheelWaveform: function(e) {
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

  pxPerSec:function() {
    return this._audio.wavesurfer.params.minPxPerSec;
  },

  zoomIn: function() {
    var pps = this.pxPerSec() + this._zoomDelta;
    console.log(pps);
    if (pps > this._maxPps) return;
    var duration = this._audio.wavesurfer.getDuration();
    this.trigger('zoom', pps, duration);
    this._audio.wavesurfer.fireEvent('zoom');
  },

  zoomOut: function() {
    var pps = this.pxPerSec() - this._zoomDelta;
    if (pps < this._minPps) return;
    var duration = this._audio.wavesurfer.getDuration();
    this.trigger('zoom', pps, duration);
    this._audio.wavesurfer.fireEvent('zoom');
  },


  onRendered: function() {
    this._loadSong();
  },

  destroy: function() {
    console.log("destroy")
    this._audio.context.close();
    this._audio.wavesurfer.destroy();
    this._destroy();
  }
});