var _ = require('underscore');
var $ = require('jquery');
var View = require('./view');
var LoadResultTemplate = require('./templates/load-result.html');

module.exports = View.extend({
  el: '#search-result',
  template: _.template(LoadResultTemplate),

  init: function(opts) {
    this.listenTo(this.model, 'change', this.onChange);
    this.listenTo(this.model, 'error', this.onError);

  },

  _clearSpin:function( ){
    $('#main .spinner-outer').remove();
  },

  _spin:function(){
    this._clearSpin();
    $('#main').append(this.fragment('spinner'));
  },

  onChange: function() {
    this._spin();
    if (this.model.get('state').load_state === 'success') {
      this.stopListening(this.model);
      this.router.navigate('song/' + this.model.get('id'), {
        trigger: true
      });
    }
    this.updateState({
      createError: false
    });
    return this.r();
  },

  onError: function(payload) {
    this._clearSpin();
    this.updateState({
      createError: payload.url
    });
  }
});