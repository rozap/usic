var Collection = require('./collection');
var Region = require('../models/region');

module.exports = Collection.extend({
  name: 'region',
  model: Region,

  _pageSize: 500,

  initialize:function(models, opts) {
    Collection.prototype.initialize.call(this, models, opts);
    if(!opts.song) throw new Error("Regions needs a song model!");
    this.song = opts.song;
    this._state.where = {
      song_id : opts.song.get('id')
    };
    this.listenTo(this._dispatcher, 'history:create:region', this.add);
  },

  modelOpts:function(opts) {
    opts.song = this.song;
    return opts;
  }

});