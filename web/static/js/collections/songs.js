var Collection = require('./collection');
var Song = require('../models/song');

console.log("Songs model is ", Song);
module.exports = Collection.extend({
  name: 'song',
  model: Song
});