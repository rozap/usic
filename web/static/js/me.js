var _ = require('underscore');
var t = require('./translate').t;
var View = require('./view');

var Me = require('./models/user');

var TranscriptionsTemplate = require('./templates/me.html');

module.exports = View.extend({
  el: '#me',
  template: _.template(TranscriptionsTemplate),

  init: function(opts) {
    this.model = new Me({}, opts);
    this.listenTo(this.model, 'change sync', this.r);
    this.model.fetch();
    this.render();
  }

});