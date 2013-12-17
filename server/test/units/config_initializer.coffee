assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
fs = require 'fs'
path = require 'path'

AppConfig = require('../../initializers/config')

suite('App Config')

configDir = path.join(__dirname, '../../', 'config')

test('.initialize when given an app, it reads the config for the env and adds a
middleware which includes that config', ->
  config = {key: 'value'}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  middleware = null
  app =
    get: (key) ->
      if key is 'env'
        return 'development'
    use: sinon.spy((theMiddleware)->
        middleware = theMiddleware
      )

  AppConfig.initialize(app)

  try
    assert.isTrue readFileStub.calledWith("#{configDir}/development.json"),
      "Expected fs.readFileSync to be called with #{configDir}/development.json but called with
      #{readFileStub.getCall(0)?.args}"
    assert.isTrue app.use.calledOnce, "Expected app.use to be called to add the middleware"

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
  env = 'pretendEnv'

  app =
    get: (key) ->
      if key is 'env'
        return env

  assert.throws((-> AppConfig.initialize(app)),
    "No config for env in #{configDir}/#{env}.json, copy config/env.json.example and edit as appropriate")
)

test(".initialize does not set the APP_CONFIG as references to the cached config object (you
  can't mutate the config)", ->
  config = {hat: boat: true}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  middleware = null
  app =
    get: -> 'development'
    use: (theMiddleware) ->
      middleware = theMiddleware

  try
    AppConfig.initialize(app)

    req = {}
    res = {locals: {}}
    middleware(req, res, ->)

    hatConfig = req.APP_CONFIG
    hatConfig.boat = false

    assert.isTrue AppConfig.get('hat').boat,
      "Expected modifying the req.APP_CONFIG not to modify the application config"

    hatConfig = res.locals.APP_CONFIG
    hatConfig.boat = false

    assert.isTrue AppConfig.get('hat').boat,
      "Expected modifying the res.locals.APP_CONFIG not to modify the application config"
  finally
    readFileStub.restore()
)

test(".get returns the values from the config", ->
  config = {hat: 'boat'}

  readFileStub = sinon.stub(fs, 'readFileSync', (path) ->
    JSON.stringify(config)
  )

  app =
    get: -> 'development'
    use: ->

  AppConfig.initialize(app)
  try
    assert.strictEqual readFileStub.callCount, 1,
      "Only expected the config file to be read once"

    assert.strictEqual AppConfig.get('hat'), config.hat,
      "Expected AppConfig.get('hat') to return the config value for hat"

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

  app =
    get: -> 'development'
    use: ->

  AppConfig.initialize(app)
  try
    hatConfig = AppConfig.get('hat')
    hatConfig.boat = false

    assert.isTrue AppConfig.get('hat').boat,
      "Expected the application config not to have been modified"
  finally
    readFileStub.restore()
)
