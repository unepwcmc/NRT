app = require('../app')
test_server = null
url = require('url')
mongoose = require('mongoose')
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

dropDatabase = (connection, done) ->
  connection.db.dropDatabase (err) ->
    if err?
      console.log 'ERROR'
      console.log err
    else
      done()

beforeEach( (done) ->
  connection = mongoose.connection
  state = connection.readyState

  if state == 2
    connection.on 'open', -> dropDatabase(connection, done)
  else if state == 1
    dropDatabase(connection, done)
)

exports.appurl = (path) ->
  url.resolve('http://localhost:3001', path)

exports.createIndicatorModels = (attributes) ->
  successCallback = errorCallback = promises = null

  Indicator = require('../models/indicator').model
  createFunctions = _.map(attributes, (attributeSet) ->
    return (callback) ->
      indicator = new Indicator(attributeSet)
      return indicator.save( (err, indicators) ->
        if err?
          callback()

        callback(null, indicators)
      )
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

