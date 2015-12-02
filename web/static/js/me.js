var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');

var Session = require('./models/session');
var Transcriptions = require('./transcriptions');
var MeTemplate = require('./templates/me.html');

module.exports = View.extend({
  el: '#main',
  template: _.template(MeTemplate),

  init: function(opts) {
    this.model = new Session({}, opts);
    this.listenTo(this.model, 'sync change', this.r);
    this.model.fetch();

    this.render();

    opts.title = 'my_transcriptions';
    opts.el = '#my-transcriptions';
    this.addSubview('transcriptions', Transcriptions, opts);
  }
});