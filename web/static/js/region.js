var _ = require('underscore');
var View = require('./view');

var RegionTemplate = require('./templates/region.html');

module.exports = View.extend({
  tagName: 'li',
  template: _.template(RegionTemplate),

  events: {
    'click': 'onSelect',
    'click .remove-region': 'onRemove',
    'click .edit-region': 'onEdit',
    'click .toggle-region-loop': 'onToggleLoop',
    'click .clone-region-right': 'onCloneRight',
    'keyup textarea': 'onEditKey'
  },

  renderTo: ['model'],

  init: function(opts) {
    this._state.pxPerSec = opts.pxPerSec;
    this._state.duration = opts.duration;
    this._state.editing = false;

    this.listenTo(this.dispatcher, 'input:onEnableSnapping',
      this.model.enableSnapping.bind(this.model)
    );
    this.listenTo(this.dispatcher, 'input:onDisableSnapping',
      this.model.disableSnapping.bind(this.model)
    );
    this.listenTo(this.dispatcher, 'input:onNudgeLeft', this.onNudgeLeft);
    this.listenTo(this.dispatcher, 'input:onNudgeRight', this.onNudgeRight);

    this.listenTo(this._parent, 'zoom', this.onZoom);
    this.listenTo(this.model, 'change', this.r);
    this.listenTo(this.model, 'destroy', this.destroy);
  },

  onSelect: function() {
    if (this.isSelected()) return;
    this.trigger('selected', this);
    this.updateState({
      isSelected: true
    });
    return this;
  },

  onDeselect: function() {
    if (!this.isSelected()) return;
    this.trigger('deselected', this);
    this.updateState({
      isSelected: false
    });
    return this;
  },

  isSelected: function() {
    return this._state.isSelected;
  },

  onEdit: function() {
    this.updateState({
      editing: true
    });
  },

  onEditKey: function(e) {
    if (e.keyCode === 13 && !e.shiftKey) {
      this.model.set('name', this.el.querySelector('textarea').value);
      this.updateState({
        editing: false
      });
    }
    e.preventDefault();
  },

  onRemove: function() {
    this.model.destroy();
  },

  onZoom: function(pps, duration) {
    this.updateState({
      pxPerSec: pps,
      duration: duration
    });
  },

  onToggleLoop: function() {
    this.model.set('loop', !this.model.get('loop'));
  },

  onNudgeRight: function(e) {
    if (!this.isSelected()) return;
    this.model.shift(this._getNudgeDelta());
  },

  onNudgeLeft: function(e) {
    if (!this.isSelected()) return;
    this.model.shift(-1 * this._getNudgeDelta());
  },

  onCloneRight:function() {
    this.trigger('cloned', this);
  },

  _getNudgeDelta: function() {
    return 1 / (this._state.pxPerSec / 2);
  },

  getAttributes: function() {
    return {
      'class': 'region' + (this._state.isSelected ? ' selected' : ''),
      'style': this.buildStyle(['width', 'left'])
    };
  },

  _width: function() {
    var seconds = (this.model.get('end') - this.model.get('start'));
    return parseInt(seconds * this._state.pxPerSec) + 'px';
  },

  _left: function() {
    return parseInt(this.model.get('start') * this._state.pxPerSec) + 'px';
  },

  waveId: function() {
    return this.model.underlyingId();
  },

  getBounds: function() {
    return {
      start: this.model.get('start'),
      end: this.model.get('end')
    };
  },

  onRendered: function() {
    if (this._state.editing) this._focusText();
  },

  _focusText: function() {
    this.$el.find('textarea').focus();
  },

  detach: function() {
    this.remove();
  }
});