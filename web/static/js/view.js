var bb = require('backbone');
var _ = require('underscore');
var t = require('./translate').t;

module.exports = bb.View.extend({
  initialize: function(opts) {
    this._subviews = {};
    this._state = {};
    this._parent = opts._parent;
    this.init(opts);
  },

  stateChange: function(listenable, event, cb) {
    this.listenTo(listenable, event, function() {
      var state = cb.apply(this, Array.prototype.slice.call(arguments));
      if (state) {
        this._state = state;
        console.log('new state', state);
        this.render();
      }
    }.bind(this));
  },

  setState: function(state) {
    this._state = state;
    this.render();
  },

  updateState: function(state) {
    this._state = _.extend({}, this._state, state);
    this.render();
  },

  getState: function() {
    return this._state;
  },

  render: function() {
    this.$el.html(this.template({
      t: t,
      state: this.getState()
    }));
    this._setAttributes(this.getAttributes());
    this.onRendered();
    return this;
  },


  getAttributes: function() {
    return {};
  },

  buildStyle: function(keys) {
    return keys.map(function(name) {
      return name + ':' + this['_' + name].call(this);
    }.bind(this)).join(';');
  },


  appendView: function(name, cls, opts) {
    var view = new cls(opts)
    this._subviews[name] = (this._subviews[name] || []);
    (this._subviews[name]).push(view);
    return view;
  },

  addSubview: function(name, cls, opts) {
    if(this._subviews[name]) this._subviews[name].destroy();
    opts._parent = this;
    var view = new cls(opts);
    this._subviews[name] = view;
    return view;
  },

  getSubview: function(name) {
    return this._subviews[name];
  },

  onRendered: function() {},
  destroy: function() {
    _.each(this._subviews, function(sub, name) {
      if (_.isArray(sub)) {
        return sub.forEach(function(view) {
          view.destroy();
        });
      }
      sub.destroy();
    });
  },

  proxy:function(name, from, to) {
    from.on(name, function() {
      to.trigger.apply(to, [name].concat(Array.prototype.slice.call(arguments)));
    });
  }
});