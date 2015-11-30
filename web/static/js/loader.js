var _ = require('underscore');
var uuid = require('uuid');
var View = require('./view');
var LoadResult = require('./load-result');

var Song = require('./models/song');

module.exports = View.extend({
  el: "#search",

  events: {
    "keyup input": "_onSearch"
  },

  init: function(opts) {
    this._state = {term: null};
  },

  _onSearch: function(e) {
    var term = e.currentTarget.value.replace(/ /g,'');
    if(this._state.term !== term) {
      this.model = new Song({}, this._opts);
      this._opts.model = this.model;
      this.addSubview('result', LoadResult, this._opts);
      this._state.term = term;
      this.model.set('url', term).save();
    }
  }
});