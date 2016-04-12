var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');
var $ = require('jquery');

var Songs = require('./collections/songs');

var TranscriptionsTemplate = require('./templates/transcriptions.html');
var FilterViewTemplate = require('./templates/filter.html');
var TranscriptionListViewTemplate = require('./templates/transcription-list.html');


var FilterView = View.extend({
  el: '#filter',
  template: _.template(FilterViewTemplate),

  init: function() {

  }
})

var TranscriptionListView = View.extend({
  el: '#transcription-list',
  template: _.template(TranscriptionListViewTemplate),
  renderTo: ['isMine'],

  init: function() {
    this.listenTo(this.model, 'change sync remove', this.r);
  },

  isMine: function(song) {
    if (!this.api) return;
    return this.api.session &&
      this.api.session.get('user') &&
      song.get('user') &&
      this.api.session.get('user').id === song.get('user').id;
  },

})


module.exports = View.extend({
  el: '#main',
  template: _.template(TranscriptionsTemplate),

  events: {
    'click .next': 'onNext',
    'click .previous': 'onPrevious',
    'click .delete-song': 'onDelete',
    'keyup .filter': 'onFilter'
  },


  init: function(opts) {
    this._state.title = opts.title || 'all_transcriptions';
    this.model = new Songs([], _.pick(opts, 'api', 'collectionState', 'dispatcher'));
    this.listenTo(this.model, 'destroy', this.fetch);
    this.listenTo(this.model, 'sync', this.r);

    this.render();
    this.addSubview('list', TranscriptionListView, {
      model: this.model
    });
    this.addSubview('filter', FilterView, {
      model: this.model
    });

    this.fetch();
  },

  fetch: function() {
    this.model.fetch();
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