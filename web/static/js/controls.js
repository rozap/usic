var $ = require('jquery');
var t = require('./translate').t;
var _ = require('underscore');
var View = require('./view');

var SlicedBufferSource = require('./sliced-buffer');
var ControlsTemplate = require('./templates/controls.html');

var KeyCodes = require('./keycodes');

var Controls = View.extend({
  el: '#controls',
  template: _.template(ControlsTemplate),
  minRate: 0.15,
  maxRate: 2,
  events: {
    'click .play-pause': 'onTogglePlay',
    'mousewheel #playback-rate': 'onWheelRate',
    'change #playback-rate': 'onChangeRate',
    'click .skip-backward': 'onSkipBackward',
    'click .skip-forward': 'onSkipForward',
    'click .auto-center': 'onAutoCenter',
    'click .show-help': 'onToggleHelp'
  },

  init: function(opts) {
    this._audio = opts.audio;

    this._audio.wavesurfer.on('seek', this._seekAudio.bind(this));
    this._audio.wavesurfer.on('play', this._playAudio.bind(this));
    this._audio.wavesurfer.on('pause', this._pauseAudio.bind(this));

    this.listenTo(this.dispatcher, 'input:onTogglePlay', this.onTogglePlay);
    this.listenTo(this.dispatcher, 'input:onSkipBackward', this.onSkipBackward);
    this.listenTo(this.dispatcher, 'input:onSkipForward', this.onSkipForward);
    this.listenTo(this.dispatcher, 'input:onUndo', this.onUndo);
    this.listenTo(this.dispatcher, 'input:onRedo', this.onRedo);

    this.listenTo(this.model, 'change:state', this.r);

    this.render();
  },

  _seekAudio: function(progress) {
    if (this.isPlaying()) this.play();
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
    st.tempo = this.model.get('state').rate;


    this._audio.stNode = soundtouch.getWebAudioNode(context, audioFilter);
    this._audio.wavesurfer.backend.setFilter(this._audio.stNode);
  },

  _pauseAudio: function() {
    if (this._audio.stNode) this._audio.stNode.disconnect();
  },


  getState: function() {
    return _.extend({}, this._state, {
      status: this.isPlaying() ? 'playing' : 'paused',
      minRate: this.minRate,
      maxRate: this.maxRate,
      rate: this.model.get('state').rate,
      pxPerSecond: this.model.get('state').pxPerSecond,
      autoCenter: this.model.get('state').autoCenter,
      keyCodes: this._genKeys()
    });
  },

  play: function() {
    if (this.isPlaying()) this.pause();
    this._audio.wavesurfer.setPlaybackRate(this.model.get('state').rate);
    this._audio.wavesurfer.play();
  },

  pause: function() {
    this._audio.wavesurfer.pause();
  },

  onChangeRate: function() {
    var rate = parseInt(this.$el.find('#playback-rate').val()) / 100;
    this._changeRate(rate);
  },

  _saveModel: _.debounce(function() {
    this.model.save()
  }, 5000),

  _changeRate: function(rate) {
    this.model.updateState({
      rate: rate
    });
    this._saveModel();
    if (this.isPlaying()) this.play();
  },

  isPlaying: function() {
    return this._audio.wavesurfer.isPlaying();
  },

  onWheelRate: function(ev) {
    var r = this.model.get('state').rate,
      min = this.minRate,
      max = this.maxRate,
      delta = 0.01;

    var rate = ev.originalEvent.wheelDelta > 0 ?
      Math.min(max, r + delta) : Math.max(min, r - delta);

    this._changeRate(rate);
  },

  onTogglePlay: function(e) {
    if (e.isDefaultPrevented()) return;
    e.preventDefault();
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
    this.render();
  },

  onSkipForward: function() {
    this._audio.wavesurfer.skipForward();
  },

  onSkipBackward: function() {
    this._audio.wavesurfer.skipBackward();
  },

  onAutoCenter: function() {
    this.model.updateState({
      autoCenter: !this.model.get('state').autoCenter
    });
    this._saveModel();
    this._audio.wavesurfer.params.follow = this.model.get('state').autoCenter;
  },

  onUndo: function() {
    this.model.undo();
  },

  onRedo: function() {
    this.model.redo();
  },

  onToggleHelp: function() {
    this.updateState({
      helpShowing: !this._state.helpShowing
    });
  },

  _genKeys: function() {
    return _.filter(KeyCodes, function(key) {
      return !!key.character;
    });
  }
});

module.exports = Controls;