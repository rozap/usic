var $ = require('jquery');
var bb = require('backbone');
var t = require('./translate').t;
var _ = require('underscore');
var View = require('./view');

var SongTemplate = require('./templates/song-title.html');

module.exports = View.extend({
  el: '#song-title',
  template: _.template(SongTemplate),

  events: {
    'click .toggle-edit': 'onToggle'
  },

  init: function() {
    this.listenTo(this.model, 'sync error', this.onSave);
    this.listenTo(this.dispatcher, 'input:onConfirm', this.onConfirm);
    this.render();
  },

  onConfirm: function(e) {
    if (!this._state.isEditing) return;
    this.model.set(this.serializeForm()).save();
  },

  onSave: function() {
    this.setState({
      isEditing: false
    });
    this._updateKeybindings();
  },

  onToggle: function() {
    this.setState({
      isEditing: !this._state.isEditing
    });
    this._updateKeybindings();
  },

  _updateKeybindings: function() {
    var binding = this._state.isEditing ? 'unbind' : 'bind';
    this.dispatcher.trigger('input:' + binding);
  }

});