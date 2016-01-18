var _ = require('underscore');
var Model = require('./model');

var saveEvents = 'change:name change:loop change:start change:end';

module.exports = Model.extend({
  name: 'region',
  defaults: {
    loop: true,
  },
  initialize: function(attrs, opts) {
    Model.prototype.initialize.call(this, attrs, opts);
    this._isSnapping = true;
    this._song = opts.song;
    this.listenTo(this, 'change', this._updateUnderlying);
    this.listenTo(this, saveEvents, _.debounce(this._saveChanges, 1000).bind(this));
  },

  addUnderlying: function(waveRegion) {
    if (this._underlying) throw new Error('only one underlying region');

    this._underlying = waveRegion;
    this._underlying.on('update', this.underlyingChange.bind(this));
    this.underlyingChange();
    return this;
  },

  enableSnapping: function() {
    this._isSnapping = true;
  },

  disableSnapping: function() {
    this._isSnapping = false;
  },

  _saveChanges: function() {
    this.save();
  },

  _snapTo: function(start, end) {
    if (!this._isSnapping) {
      return {
        start: start,
        end: end
      };
    }

    var s = this._song.get('state')
    var markers = s.clicks.concat(s.measures);
    var snap = function(position) {
      return markers.reduce(function(eps, click) {
        var clickEps = click - position;
        if (Math.abs(clickEps) < Math.abs(eps)) return clickEps;
        return eps;
      }, Infinity);
    }.bind(this);

    var threshold = 0.5;
    var deltaStart = snap(start);
    var deltaEnd = snap(end);

    if (Math.abs(deltaStart) > threshold) deltaStart = 0;
    if (Math.abs(deltaEnd) > threshold) deltaEnd = 0;

    return {
      start: start + deltaStart,
      end: end + deltaEnd
    };
  },

  _updateUnderlying: function(bounds) {
    if(!this._underlying) return;
    this._underlying.update(bounds, true);
    this._underlying.loop = this.get('loop');
  },

  underlyingChange: function(region) {
    var bounds = this._snapTo(this._underlying.start, this._underlying.end);
    this._updateUnderlying(bounds);
    this.set({
      start: bounds.start,
      end: bounds.end
    });
  },

  shift: function(delta) {
    var bounds = {
      start: this.get('start') + delta,
      end: this.get('end') + delta
    };
    this._updateUnderlying(bounds);
    this.set(bounds);
  },

  destroy: function() {
    this._underlying.remove();
    Model.__super__.destroy.call(this);
  },

  underlyingId: function() {
    return this._underlying.id;
  }
});