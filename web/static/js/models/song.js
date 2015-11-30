var Model = require('./model');
var _ = require('underscore');


module.exports = Model.extend({
  name: 'song',
  defaults: {
    'state': {}
  },

  updateState:function(ns) {
    var s = _.extend({}, this.get('state'), ns);
    this.set('state', s);
  },

  toJSON:function() {
    var attrs = _.clone(this.attributes);
    attrs.state = _.clone(this.get('state'));
    return attrs;
  }
});