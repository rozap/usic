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

module.exports = View.extend({
  el: '#main',
  template: _.template(SongTemplate),
  _audio: {},
  _zoomDelta: 2,
  _panDelta: 30,
  _maxPps: 106, //TODO: why does it go to shit at 106
  _minPps: 2,
  _pan: 0,

  events: {
    'mousewheel .interactive': 'onWheelWaveform',
    'keydown': 'onKeyDown'
  },

  init: function(opts) {
    this.model = new Song({id: opts.id}, this._opts);
    this.listenToOnce(this.model, 'sync', this._loadSong);


    this.model.fetch();
  },

  _loadSong: function() {
    this.render();

    this.addSubview('song-title', SongTitle, {
      model:this.model
    });

    this.model.resetHistory();
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

    var regionsView = this.addSubview('regions', RegionView, {
      wavesurfer: wavesurfer,
      model: this.model,
      dispatcher: this.dispatcher,
      api: this.api
    });
    this.listenTo(regionsView, 'scroll', this.panTo);

    this._audio.wavesurfer = wavesurfer;
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

  destroy: function() {
    if(this._audio.wavesurfer) this._audio.wavesurfer.destroy();
    this._destroy();
  }
});