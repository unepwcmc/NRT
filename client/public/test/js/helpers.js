(function() {
  var ENV, teardownDb;

  ENV = process.env.NODE_ENV;

  GLOBAL.sequelize || (GLOBAL.sequelize = require('../model_bindings.coffee')(ENV));

  teardownDb = function() {
    return sequelize.sync({
      force: true
    });
  };

  before(function() {
    return teardownDb();
  });

}).call(this);
