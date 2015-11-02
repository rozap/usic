var _ = require('underscore');
var View = require('./view');
var Song = require('./song');
var ErrorTemplate = require('./templates/error.html');

module.exports = View.extend({
  el: '#error',
  template: _.template(ErrorTemplate),

  events : {
    'click .dismiss-error': 'onErrorDismiss'
  },

  init: function(opts) {
    this.listenTo(opts.dispatcher, 'error:new', this.onError);
    this.listenTo(opts.dispatcher, 'error:dismiss', this.onErrorDismiss);
  },

  onError: function(message, opts) {
    this.setState(_.extend({}, opts, {
      hasError: true,
      message: message
    }));
  },

  onErrorDismiss: function() {
    this.setState({
      hasError: false
    });
  }
});