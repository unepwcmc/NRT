assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
fs = require 'fs'
path = require 'path'

ConfigInitializer = require('../../initializers/config')

suite('Config Initializer')

configDir = path.join(__dirname, '../../', 'config')

test('when given an app, it reads the config for the env and adds a
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

  ConfigInitializer(app)

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

test("when there is no config file for the given environemnt, it throws
an appropriate message", ->
  env = 'pretendEnv'

  app =
    get: (key) ->
      if key is 'env'
        return env

  assert.throws((-> ConfigInitializer(app)),
    "No config for env in #{configDir}/#{env}.json, copy config/env.json.example and edit as appropriate")
)
