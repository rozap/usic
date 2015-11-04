var bb = require('backbone');
var _ = require('underscore');


module.exports = bb.Model.extend({
  defaults: {
    'clicks': [],
  }
});