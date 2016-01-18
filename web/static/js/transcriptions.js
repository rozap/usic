var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');
var $ = require('jquery');

var Songs = require('./collections/songs');

var TranscriptionsTemplate = require('./templates/transcriptions.html');

module.exports = View.extend({
  el: '#main',
  template: _.template(TranscriptionsTemplate),

  events: {
    'click .next': 'onNext',
    'click .previous': 'onPrevious',
    'click .delete-song': 'onDelete'
  },

  renderTo: ['isMine'],

  init: function(opts) {
    this._state.title = opts.title || 'all_transcriptions';
    this.model = new Songs([], _.pick(opts, 'api', 'collectionState', 'dispatcher'));
    this.listenTo(this.model, 'change sync remove', this.r);
    this.listenTo(this.model, 'destroy', this.fetch);

    this.fetch();
    this.render();
  },

  fetch: function() {
    this.model.fetch();
  },

  isMine: function(song) {
    if(!this.api) return;
    return this.api.session &&
      this.api.session.get('user') &&
      song.get('user') &&
      this.api.session.get('user').id === song.get('user').id;
  },

  onNext: function() {
    this.model.next();
  },

  onPrevious: function() {
    this.model.previous();
  },

  onDelete: function(e) {
    var songId = parseInt($(e.currentTarget).data('id'));
    var song = this.model.get(songId);
    song.destroy();
  }
});