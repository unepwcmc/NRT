app = require('../app')
test_server = null
url = require('url')
_ = require('underscore')
async = require('async')

before( (done) ->
  app.start 3001, (err, server) ->
    test_server = server
    done()
)

after( (done) ->
  test_server.close () -> done()
)

beforeEach( (done) ->
  global.sequelize.sync({force: true}).success(() -> done())
)

exports.appurl = (path) ->
  url.resolve('http://localhost:3001', path)

exports.createIndicatorModels = (attributes) ->
  successCallback = errorCallback = promises = null

  Indicator = require('../models/indicator')
  createFunctions = _.map(attributes, (attributeSet) ->
    return (callback) ->
      return Indicator.create(attributeSet)
        .success((indicators)->
          callback(null, indicators)
        ).error(callback)
  )

  async.parallel(
    createFunctions,
    (error, results) ->
      if error?
        errorCallback(error, results) if errorCallback?
      else
        successCallback(results) if successCallback?
  )

  promises = {
    success: (callback)->
      successCallback = callback
      return promises
    error: (callback)->
      errorCallback = callback
      return promises
  }
  return promises
