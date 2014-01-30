assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
fs = require 'fs'
path = require 'path'

appConfig = require('../../initializers/config')

suite('App Config')

configDir = path.join(__dirname, '../../', 'config')

test('.initialize returns the middleware containing the app config', -
  middleware = appConfig.initialize()

  assert.isNotNull middleware, "Expected the middleware to be assigned"

  req = {}
  res = {locals: {}}
  next = sinon.spy()
  middleware(req, res, next)

  assert.isTrue next.calledOnce, "Expected the next function to be called by the middleware"
  assert.property req, 'APP_CONFIG',
    "Expected the middleware to create req.APP_CONFIG"
  assert.property res.locals, 'APP_CONFIG',
    "Expected the middleware to create locals.APP_CONFIG"
)
