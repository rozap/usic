var $ = require('jquery');
var t = require('./translate').t;
var _ = require('underscore');
var View = require('./view');

var SlicedBufferSource = require('./sliced-buffer');
var ControlsTemplate = require('./templates/controls.html');
var keyCodes = require('./keycodes');

var Controls = View.extend({
  el: '#controls',
  template: _.template(ControlsTemplate),

  events: {
    'click .play-pause': 'onSpace',
    'mousewheel #playback-rate': 'onWheelRate',
    'change #playback-rate': 'onChangeRate'
  },

  init: function(opts) {
    this._audio = opts.audio;

    this._audio.wavesurfer.on('seek', this._seekAudio.bind(this));
    this._audio.wavesurfer.on('play', this._playAudio.bind(this));
    this._audio.wavesurfer.on('pause', this._pauseAudio.bind(this));

    this._state = {
      rate: 1,
      pxPerSecond: 50,
      minRate: 0.15,
      maxRate: 2
    };

    this.render();
  },

  _seekAudio: function(progress) {
    if(this.isPlaying()) this.play();
  },

  _playAudio: function() {
    var context = this._audio.wavesurfer.backend.getAudioContext();
    var st = new soundtouch.SoundTouch(this._audio.buffer.sampleRate);
    var source = new SlicedBufferSource(
      this._audio.buffer,
      Math.floor(this._audio.buffer.sampleRate * this._audio.wavesurfer.getCurrentTime())
    );
    var audioFilter = new soundtouch.SimpleFilter(
      source,
      st
    );
    st.tempo = this._state.rate;


    this._audio.stNode = soundtouch.getWebAudioNode(context, audioFilter);
    this._audio.wavesurfer.backend.setFilter(this._audio.stNode);
  },

  _pauseAudio: function() {
    if(this._audio.stNode) this._audio.stNode.disconnect();
  },


  getState: function() {
    return _.extend({}, this._state, {
      status: this.isPlaying() ? 'playing' : 'paused'
    });
  },

  onKeyUp: function(ev) {
    var func = this[keyCodes[ev.keyCode]];
    if (func) func.call(this, ev);
  },

  onWheelRate: function(ev) {
    var r = this._state.rate,
        min = this._state.minRate,
        max = this._state.maxRate,
        delta = 0.01;

    var rate = ev.originalEvent.wheelDelta > 0 ?
      Math.min(max, r + delta) : Math.max(min, r - delta);

    this._changeRate(rate);
  },

  play: function() {
    if (this.isPlaying()) this.pause();
    this._audio.wavesurfer.setPlaybackRate(this._state.rate);
    this._audio.wavesurfer.play();
  },

  pause: function() {
    this._audio.wavesurfer.pause();
  },

  onChangeRate: function() {
    var rate = parseInt(this.$el.find('#playback-rate').val()) / 100;
    this._changeRate(rate);
  },

  _changeRate:function(rate) {
    this.updateState({
      rate: rate
    });
    if (this.isPlaying()) this.play();
  },

  isPlaying: function() {
    return this._audio.wavesurfer.isPlaying();
  },

  onTogglePlay: function() {
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
    this.render();
  },

  onRendered: function() {
    $('body').unbind('keyup').bind('keyup', this.onKeyUp.bind(this));
  },
});

module.exports = Controls;