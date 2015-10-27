var _ = require('underscore');
var View = require('./view');

var WaveTemplate = require('./templates/wave.html');

module.exports = View.extend({
  template : _.template(WaveTemplate),
  el : '#view-wave',
  init:function(opts) {
    this.render();
    this._initUnderlying(opts);
    this.listenTo(this._parent, 'pan', this.panTo);
    this.listenTo(this._parent, 'zoom', this.zoomTo);

  },

  _initUnderlying:function(opts) {
    var wavesurfer = Object.create(WaveSurfer);
    wavesurfer.init({
      container: '#waveform',
      waveColor: '#db9e36',
      progressColor: 'rgba(0, 0, 0, 0)',
      hideScrollbar: false,
      scrollParent: true,
      minPxPerSec: 10
    });
    wavesurfer.enableDragSelection({});

    wavesurfer.loadDecodedBuffer(opts.buf);
    this._wavesurfer = wavesurfer;
  },

  wv:function() {
    return this._wavesurfer;
  },

  getWidth: function() {
    return this._wavesurfer.getDuration() * this._wavesurfer.params.minPxPerSec;
  },

  panTo:function(p) {
    this.$el.find('wave').scrollLeft(p);
  },

  zoomTo:function(pps, _duration) {
    this._wavesurfer.zoom(pps);
  },


});
