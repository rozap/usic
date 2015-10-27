var bb = require('backbone');
var _ = require('underscore');


module.exports = bb.Model.extend({
  initialize: function(wvRegion, name) {
    wvRegion.loop = true;
    this._underlying = wvRegion;
    this._underlying.on('update', this.underlyingChange.bind(this))
    this.set({
      name: name
    });
    this._updateUnderlying();
  },

  _updateUnderlying: function() {
    this.set({
      start: this._underlying.start,
      end: this._underlying.end,
      id: this._underlying.id
    })
  },

  underlyingChange: function(region) {
    this._updateUnderlying();
  }
});