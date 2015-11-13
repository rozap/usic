var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');

var Songs = require('./collections/songs');

var TranscriptionsTemplate = require('./templates/transcriptions.html');

module.exports = View.extend({
  el: '#transcriptions',
  template: _.template(TranscriptionsTemplate),

  events : {
    'click .next' : 'onNext',
    'click .previous' : 'onPrevious'
  },

  init: function(opts) {
    window.thing = this;
    this.model = new Songs([], opts);
    this.listenTo(this.model, 'change sync', this.r);
    this.model.fetch()
    this.render();
  },

  onNext:function() {
    this.model.next();
  },

  onPrevious:function() {
    this.model.previous();
  }

});