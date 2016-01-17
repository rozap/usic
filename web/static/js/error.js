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
    window.thing = this;
    this.listenTo(opts.dispatcher, 'error:new', this.onError);
    this.listenTo(opts.dispatcher, 'error:dismiss', this.onDismissError);
  },

  onError: function(err, opts) {
    console.warn('got an error', err);
    //only show the first one, preventing cascading weirdness
    if(this.getState().hasError) return this.bounce();
    this.setState(_.extend({}, opts, {
      hasError: true,
      error: err,
      dismissed: false
    }));
  },

  bounce:function( ){
    this.$el.animate({
      'padding-left': '0em'
    }, 100, this.onRendered.bind(this));
  },

  onRendered:function( ){
    this.$el.animate({
      'padding-left': '1em'
    }, 300);
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