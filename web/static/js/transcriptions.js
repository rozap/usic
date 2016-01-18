var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');

var Songs = require('./collections/songs');

var TranscriptionsTemplate = require('./templates/transcriptions.html');

module.exports = View.extend({
  el: '#main',
  template: _.template(TranscriptionsTemplate),

  events : {
    'click .next' : 'onNext',
    'click .previous' : 'onPrevious'
  },

  init: function(opts) {
    this._state.title = opts.title || 'all_transcriptions';
    this.model = new Songs([], _.pick(opts, 'api', 'dispatcher'));
    this.listenTo(this.model, 'change sync', this.r);
    this.model.fetch();
    this.render();
  },

  onNext:function() {
    this.model.next();
  },

  onPrevious:function() {
    this.model.previous();
  }
});