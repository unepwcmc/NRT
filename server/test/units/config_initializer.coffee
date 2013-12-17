assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
fs = require 'fs'
path = require 'path'

appConfig = require('../../initializers/config')

suite('App Config')

configDir = path.join(__dirname, '../../', 'config')

test('.initialize when given an app, it reads the config for the env and returns a
  middleware which includes that config', ->
  config = {key: 'value'}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  middleware = appConfig.initialize()

  try
    assert.isTrue readFileStub.calledWith("#{configDir}/test.json"),
      "Expected fs.readFileSync to be called with #{configDir}/test.json but called with
      #{readFileStub.getCall(0)?.args}"

    assert.isNotNull middleware, "Expected the middleware to be assigned"

    req = {}
    res = {locals: {}}
    next = sinon.spy()
    middleware(req, res, next)

    assert.isTrue next.calledOnce, "Expected the next function to be called by the middleware"
    assert.property req, 'APP_CONFIG',
      "Expected the middleware to create req.APP_CONFIG"
    assert.deepEqual req.APP_CONFIG, config,
      "Expected the middleware to set req.APP_CONFIG to the application config"

    assert.property res.locals, 'APP_CONFIG',
      "Expected the middleware to create locals.APP_CONFIG"
    assert.deepEqual res.locals.APP_CONFIG, config,
      "Expected the middleware to set res.locals.APP_CONFIG to the application config"
  finally
    readFileStub.restore()
)

test(".initialize when there is no config file for the given environemnt, it throws
  an appropriate message", ->
  oldNodeEnv = process.env.NODE_ENV
  process.env.NODE_ENV = env = 'pretendEnv'

  try
    assert.throws((-> appConfig.initialize()),
      "No config for env in #{configDir}/#{env}.json, copy config/env.json.example and edit as appropriate")
  finally
    process.env.NODE_ENV = oldNodeEnv
)

test(".initialize does not set the APP_CONFIG as references to the cached config object (you
  can't mutate the config)", ->
  config = {hat: boat: true}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  middleware = null

  try
    middleware = appConfig.initialize()

    req = {}
    res = {locals: {}}
    middleware(req, res, ->)

    hatConfig = req.APP_CONFIG
    hatConfig.boat = false

    assert.isTrue appConfig.get('hat').boat,
      "Expected modifying the req.APP_CONFIG not to modify the application config"

    hatConfig = res.locals.APP_CONFIG
    hatConfig.boat = false

    assert.isTrue appConfig.get('hat').boat,
      "Expected modifying the res.locals.APP_CONFIG not to modify the application config"
  finally
    readFileStub.restore()
)

test(".get returns the values from the config", ->
  config = {hat: 'boat'}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  appConfig.initialize()

  try
    assert.strictEqual readFileStub.callCount, 1,
      "Only expected the config file to be read once"

    assert.strictEqual appConfig.get('hat'), config.hat,
      "Expected appConfig.get('hat') to return the config value for hat"

    assert.strictEqual readFileStub.callCount, 1,
      "Expected the config file not to be read again after initialization"
  finally
    readFileStub.restore()
)

test(".get does not return a reference to the cached config object (you
  can't mutate the config)", ->
  config = {hat: boat: true}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  appConfig.initialize()

  try
    hatConfig = appConfig.get('hat')
    hatConfig.boat = false

    assert.isTrue appConfig.get('hat').boat,
      "Expected the application config not to have been modified"
  finally
    readFileStub.restore()
)
