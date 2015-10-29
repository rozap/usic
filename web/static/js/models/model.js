var bb = require('backbone');

module.exports = bb.Model.extend({
  sync: function(method, model, options) {
    console.log(method, model, options);
    return this;
  }
})