var _ = require('underscore');
var View = require('./view');
var Song = require('./song');
var ErrorTemplate = require('./templates/error.html');

module.exports = View.extend({
  el: '#error',
  template: _.template(ErrorTemplate),

  events : {
    'click .minimize-error': 'onMinimizeError'
  },

  init: function(opts) {
    this.listenTo(opts.dispatcher, 'error:new', this.onError);
    this.listenTo(opts.dispatcher, 'error:dismiss', this.onDismissError);
  },

  onError: function(message, opts) {
    //only show the first one, preventing cascading weirdness
    if(this.getState().hasError) return;
    this.setState(_.extend({}, opts, {
      hasError: true,
      message: message,
      dismissed: false
    }));
  },

  onDismissError:function() {
    this.setState({
      hasError: false
    });
  },

  onMinimizeError: function() {
    this.updateState({
      dismissed: true
    });
  }
});