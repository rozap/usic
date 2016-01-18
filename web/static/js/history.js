function History(dispatcher) {
  this.resetHistory();
  this.dispatcher = dispatcher;
  this.dispatcher.on('all', function(a, b, c){
    console.log(a, b, c);
  });

  this.dispatcher.on('history:create:region', this._onRegionCreate.bind(this));
    // this.listenTo(this.dispatcher, 'request:update:song', this._onSongUpdate);
  this.dispatcher.on('input:onUndo', this._onUndo.bind(this));
  this.dispatcher.on('input:onRedo', this._onRedo.bind(this));

}

History.prototype = {
  destroy: function() {

  },

  _onSongUpdate: function(song) {
    var behind = song.toJSON();
    this._behind.push(function() {
      var ahead = song.toJSON();
      song.set(behind);
      return function() {
        song.set(ahead);
      };
    });
  },

  _onRegionCreate: function(region) {
    var old = region.toJSON();
    this._behind.push(function() {
      region.destroy();
      return function() {
        region.clone().save();
      };
    });
  },

  // onUndo: function() {
  //   this.model.undo();
  // },

  // onRedo: function() {
  //   this.model.redo();
  // },


  // var opts = _.last(args) || {}
  // if (!opts.untracked && this._behind != null) {
  // this._behind.push(this.toJSON());
  // this._ahead = [];
  // }


  _onRedo: function() {
    var fn = this._ahead.pop();
    if (!fn) return;
    fn();
  },

  _onUndo: function() {
    var fn = this._behind.pop();
    if (!fn) return;
    this._ahead.push(fn());
  },

  resetHistory: function() {
    this._ahead = [];
    this._behind = [];
  }
};

module.exports = History;