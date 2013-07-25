ENV = process.env.NODE_ENV

GLOBAL.sequelize ||= require('../model_bindings.coffee')(ENV)

app = require('../app.coffee')

teardownDb = ->
  sequelize.sync({force: true})

startServer = (callback) ->
  app.start(3001, callback)

before( (done) ->
  teardownDb()
  startServer(done)
)
