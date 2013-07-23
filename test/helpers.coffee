ENV = process.env.NODE_ENV

GLOBAL.sequelize ||= require('../model_bindings.coffee')(ENV)

teardownDb = ->
  sequelize.sync({force: true})

before( ->
  teardownDb()
)
