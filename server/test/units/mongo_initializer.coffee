assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
fs = require 'fs'
mongoose = require 'mongoose'

AppConfig = require('../../initializers/config')
MongoInitializer = require('../../initializers/mongo')

suite('Mongo initializer')

test('connects to the mongo DB named in the config', ->
  sandbox = sinon.sandbox.create()
  appConfigGetStub = sandbox.stub(AppConfig, 'get', ->
    name: 'nrt-demo'
  )
  mongooseConnectStub = sandbox.stub(mongoose, 'connect', ->)

  try
    MongoInitializer('dev')

    assert.isTrue appConfigGetStub.calledWith('db'),
      "Expected the initalizer to query the app config for db config"

    assert.isTrue(
      mongooseConnectStub.calledWith('mongodb://localhost/nrt-demo'),
      "Expected the initializer to connect to the database 'nrt-demo'"
    )

  finally
    sandbox.restore()
)

test('if no db config exists, it throws an error', ->
  sandbox = sinon.sandbox.create()
  appConfigGetStub = sandbox.stub(AppConfig, 'get', ->
    undefined
  )
  mongooseConnectStub = sandbox.stub(mongoose, 'connect', ->)

  try
    assert.throws(
      (-> MongoInitializer('dev')),
      "Couldn't connect to database, no db config found in application config. See the app config README for setup instructions."
    )
  finally
    sandbox.restore()
)

test("if db config exists but doesn't specify a name, it throws an error", ->
  sandbox = sinon.sandbox.create()
  appConfigGetStub = sandbox.stub(AppConfig, 'get', ->
    {}
  )
  mongooseConnectStub = sandbox.stub(mongoose, 'connect', ->)

  try
    assert.throws(
      (-> MongoInitializer('dev')),
      "Couldn't connect to database, db config doesn't specify a name. See the app config README for setup instructions."
    )
  finally
    sandbox.restore()
)
