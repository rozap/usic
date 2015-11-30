var _ = require('underscore');
var View = require('./view');
var LoadResultTemplate = require('./templates/load-result.html');

module.exports = View.extend({
  el: '#search-result',
  template: _.template(LoadResultTemplate),

  init: function(opts) {
    this.listenTo(this.model, 'change', this.onChange);
  },

  onChange: function() {
    if(this.model.get('state').load_state === 'load_complete') {
      this.stopListening(this.model);
      this.router.navigate('song/' + this.model.get('id'), {trigger: true})
    }
    return this.r();
  },

});