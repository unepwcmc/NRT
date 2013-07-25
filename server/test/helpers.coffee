ENV = process.env.NODE_ENV

GLOBAL.sequelize ||= require('../model_bindings.coffee')(ENV)

app = require('../app.coffee')
async = require('async')
test_server = null


beforeEach( (done) ->
  sequelize.sync({force: true}).success( ->
    app.start 3001, (err, server) ->
      test_server = server
      done(err)
  )
)

afterEach( (done) ->
  test_server.close done
)
