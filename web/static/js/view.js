var bb = require('backbone');
var _ = require('underscore');
var t = require('./translate').t;
var moment = require('moment');

module.exports = bb.View.extend({

  initialize: function(opts) {
    this.api = opts.api;
    this.dispatcher = opts.dispatcher;
    this._subviews = {};
    this._opts = opts;
    this._state = {};
    this._parent = opts._parent;
    if(!this.dispatcher) throw new Error('wtf m9');
    this.init(opts);
  },

  stateChange: function(listenable, event, cb) {
    this.listenTo(listenable, event, function() {
      var state = cb.apply(this, Array.prototype.slice.call(arguments));
      if (state) {
        this._state = state;
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

  _getState:function() {
    var s = {};
    if(this.renderTo) {
      this.renderTo.forEach(function(name) {
        s[name] = this[name];
      }.bind(this));
    }
    s.model = this.model;
    return _.extend(s, this.getState());
  },

  getState: function() {
    return this._state;
  },

  r:function() {
    this.render();
  },

  render: function(parentState) {
    parentState = parentState || (this._parent && this._parent.getState()) || {};
    var state = _.extend(parentState, this._getState());
    this.$el.html(this.template({
      t: t,
      _: _,
      moment: moment,
      state: state
    }));

    if(state.cid) throw new Error("wtf m8");

    this._setAttributes(this.getAttributes());

    //render all the kids, replacing their element with the new one
    _.each(this._subviews, function(view) {
      if(!_.isArray(view)) {
        view.setElement(document.querySelector(this._rebuildSelector(view)));
        //state tree
        view.render(_.clone(state));
      }
    }.bind(this));

    this.onRendered(state);
    return this;
  },

  _rebuildSelector:function(view) {
    if(!view.el) return;
    var classes = view.el.className.split(' ');
    return view.el.tagName.toLowerCase() + '#' + view.el.id + (view.el.className? ('.' + classes.join('.')): '');
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
    opts._parent = this;
    opts.dispatcher = this.dispatcher;
    var view = new cls(opts);
    this._subviews[name] = (this._subviews[name] || []);
    this.listenTo(view, 'destroy', _.partial(this._removeAppended, name));
    (this._subviews[name]).push(view);

    return view;
  },

  addSubview: function(name, cls, opts) {
    opts = opts || {};
    if(this._subviews[name]) this._subviews[name].destroy();
    opts._parent = this;
    opts.dispatcher = this.dispatcher;
    var view = new cls(opts);
    this._subviews[name] = view;
    this.listenTo(view, 'destroy', _.partial(this._removeAdded, name));
    return view;
  },

  _removeAppended:function(name, view) {
    this._subviews[name] = _.without(this._subviews[name], view);
    this.render();
  },

  _removeAdded:function(name) {
    delete this._subviews[name];
    this.render();
  },

  getSubview: function(name) {
    return this._subviews[name];
  },

  onRendered: function(state) {},
  _destroy: function() {
    _.each(this._subviews, function(sub, name) {
      if (_.isArray(sub)) {
        return sub.forEach(function(view) {
          view.destroy();
        });
      }
      sub.destroy();
    });
    this.detach();
    this.trigger('destroy', this);
  },

  detach:function() {
    this.stopListening();
    this.undelegateEvents();
    this.$el.html('');
  },

  destroy:function() {
    this._destroy();
  },

  serializeForm:function(name) {
    name = name || 'form';
    var inputs = this.el
    .querySelector(name)
    .querySelectorAll('input');

    return _.object(
    _.range(0, inputs.length)
    .map(function(i) {
      var element = inputs[i];
      return [element.name, element.value];
    }));
  }
});