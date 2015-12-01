var Collection = require('./collection');
var Song = require('../models/song');

module.exports = Collection.extend({
  name: 'song',
  model: Song
});