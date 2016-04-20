var Model = require('./model');
var _ = require('underscore');


module.exports = Model.extend({
  name: 'song',
  defaults: {
    'state': {}
  },

  updateState: function(ns) {
    var s = _.extend({}, this.get('state'), ns);
    return this.set('state', s);
  },

  toJSON: function() {
    var attrs = _.clone(this.attributes);
    attrs.state = _.clone(this.get('state'));
    return attrs;
  },

  getSortedRegions: function() {
    if(!this.get('regions')) return [];
    var regions = _.clone(this.get('regions'));
    regions.sort(function(r0, r1) {
      return r0.start > r1.start ? 1 : -1;
    });
    return regions;
  }
});