var _ = require('underscore');
var View = require('./view');
var $ = require('jquery');

var ClicksTemplate = require('./templates/clicks.html');


module.exports = View.extend({
  template: _.template(ClicksTemplate),
  el: '#view-clicks',

  renderTo: ['model'],

  events: {
    // 'mousedown': 'onSelectStart',
    // 'mouseup': 'onSelectEnd',
    'mousedown .draggable': 'onDragStart',
    'mouseup .draggable': 'onDragEnd',
    'mousemove': 'onMouseMove',
    'click .draggable': 'onSelectDraggable'
  },

  init: function(opts) {
    this._wavesurfer = opts.wavesurfer;
    this.model = opts.model;
    this.listenTo(this.model, 'change', this.r);
    this.render();
    this.listenTo(this.dispatcher, 'input:onBeatCreated', this.onBeatCreated);
    this.listenTo(this.dispatcher, 'input:onMeasureCreated', this.onMeasureCreated);

  },

  getState: function() {
    return {
      scale: this._wavesurfer.params.minPxPerSec,
      height: 48
    };
  },

  save: _.debounce(function() {
    if (this._dragging) return;
    this.model.save();
  }, 1000),

  _appendMarker: function(name) {
    var state = _.clone(this.model.get('state'));
    state[name] = state[name].concat([this._wavesurfer.getCurrentTime()]);
    this.model
      .set('state', state)
      .trigger('change');
    this.save();

  },

  onBeatCreated: function() {
    this._appendMarker('clicks');
  },

  onMeasureCreated: function() {
    this._appendMarker('measures');
  },

  timeToPixels: function(timeOffset) {
    return this._state.scale * timeOffset;
  },

  pixelsToTime: function(pixelOffset) {
    return pixelOffset / this._wavesurfer.params.minPxPerSec;
  },

  onDragStart: function(e) {
    var $t = $(e.currentTarget);
    this._dragging = {
      el: $t,
      position: parseInt($t.data('position')),
      kind: $t.data('kind')
    };
  },

  onDragEnd: function() {
    if(!this._dragging.el) return;
    var state = _.clone(this.model.get('state'));
    var offsetX = parseFloat(this._dragging.el.attr('x'));
    state[this._dragging.kind][this._dragging.position] = this.pixelsToTime(offsetX);
    this._dragging = false;
    this.model
      .set('state', state)
      .trigger('change');
    this.save();
  },

  onMouseMove: function(e) {
    if (this._dragging) {
      var xPixels = e.offsetX;
      this._dragging.el.attr('x', xPixels);
      return;
    }
    // var s = this._state.selection;
    // if (s) {
    //   this.updateState({
    //     selection: {
    //       from: Math.min(s.from, s.to),
    //       to: Math.max(s.from, s.to)
    //     }
    //   });
    //   return;
    // }
  },

  onSelectDraggable: function(e) {
    if(!e.ctrlKey) return;
    var $t = $(e.currentTarget);
    var kind = $t.data('kind');
    var position = $t.data('position');
    delete state[kind][position];
    this.model
      .set('state', state)
      .trigger('change');
    this.save();
  }

  // onSelectStart: function(e) {
  //   if (e.isDefaultPrevented()) return;
  //   this._selecting.from = e.offsetX;
  //   this._selecting.to = e.offsetX;
  // },

  // onSelectEnd: function(e) {
  //   if (e.isDefaultPrevented()) return;
  // }


});