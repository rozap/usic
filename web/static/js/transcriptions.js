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
  events : {
    'keyup .filter': 'onFilter'
  },
  init: function() {
    this.render();
  },

  _buildWhere: function(filter) {
    var toks = filter.split(' ')

    var things = _.partition(toks, function(tok) {
      return tok.startsWith("#")
    });
    var regions = things[0].map(function(tag) {
      return tag.slice(1);
    });
    var name = things[1].join(' ').trim();

    if(regions.length || name.length) {
      var q = {};
      if(regions.length) q.regions = regions;
      if(name.length) q.name = name;
      return q;
    }
    return {};
  },

  onFilter:function(e) {
    var filter = $(e.currentTarget).val()
    var q = this._buildWhere(filter);
    this.model.updateState("where", q);
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
    'click .delete-song': 'onDelete'
  },


  init: function(opts) {
    this._state.title = opts.title || 'all_transcriptions';
    this.model = new Songs([], _.pick(opts, 'api', 'collectionState', 'dispatcher'));
    this.listenTo(this.model, 'destroy', this.fetch);

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