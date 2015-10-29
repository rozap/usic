var _ = require('underscore');
var Model = require('./model');

module.exports = Model.extend({
  initialize: function(wvRegion, name, song) {
    this._song = song;
    this._isSnapping = true;
    this._underlying = wvRegion;
    this._underlying.on('update', this.underlyingChange.bind(this));
    this.listenTo(this, 'change', this._updateUnderlying);
    this.set({
      name: name,
      loop: true
    });
    this.underlyingChange();
  },

  enableSnapping: function() {
    this._isSnapping = true;
  },

  disableSnapping: function() {
    this._isSnapping = false;
  },

  _snapTo: function(start, end) {
    if (!this._isSnapping) {
      return {
        start: start,
        end: end
      };
    }

    var snap = function(position) {
      return this._song.get('clicks').reduce(function(eps, click) {
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
    this._underlying.update(bounds, true);
    console.log("UPDATE UNDER")
    this._underlying.loop = this.get('loop');
  },

  underlyingChange: function(region) {
    var bounds = this._snapTo(this._underlying.start, this._underlying.end);
    this._updateUnderlying(bounds);
    this.set({
      start: bounds.start,
      end: bounds.end,
      id: this._underlying.id
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
  }
});