(function() {
  var Narrative, assert, helpers;

  assert = require('chai').assert;

  helpers = require('../helpers');

  Narrative = require('../../models/narrative');

  suite('Narrative');

  test('.create', function() {
    return Narrative.create({
      title: '1234',
      content: 'narrate this'
    }).success(function() {
      console.log('created narrative');
      return Narrative.findAndCountAll().success(function(count) {
        return assert.equal(1, count);
      });
    });
  });

}).call(this);
