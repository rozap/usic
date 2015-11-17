var _ = require('underscore');
var View = require('./view');
var Song = require('./song');
var LoadResultTemplate = require('./templates/loader.html');

module.exports = View.extend({
  el: '#search-result',
  template: _.template(LoadResultTemplate),

  init: function(opts) {
    this.stateChange(opts._parent, 'reply:search', this._update);
  },

  _update: function(state) {
    if(state.state === 'success') {
      console.log("making song", state)
      if(this._songView) this._songView.destroy();
      this._songView = new Song({
        result: state,
        dispatcher: this.dispatcher,
        api: this.api
      });

      document.querySelector('#search-input').blur();
    }
    return state;
  },

});