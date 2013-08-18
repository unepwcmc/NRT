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

Report = require('../models/report').model
Indicator = require('../models/indicator').model
Visualisation = require('../models/visualisation').model
Narrative = require('../models/narrative').model
Section = require('../models/section').model

exports.createReport = (attributes, callback) ->
  if arguments.length == 1
    callback = attributes
    attributes = undefined

  report = new Report(attributes || title: "new report")

  report.save (err, report) ->
    if err?
      throw 'could not save report'

    callback(report)

exports.createIndicator = (callback) ->
  indicator = new Indicator(
    title: "new indicator"
  )

  indicator.save (err, indicator) ->
    if err?
      throw 'could not save indicator'

    callback(null, indicator)

exports.createVisualisation = (callback) ->
  visualisation = new Visualisation(
    data: "new visualisation"
  )

  visualisation.save (err, Visualisation) ->
    if err?
      throw 'could not save visualisation'

    callback(null, visualisation)

exports.createNarrative = (callback) ->
  narrative = new Narrative(
    content: "new narrative"
  )

  narrative.save (err, narrative) ->
    if err?
      throw 'could not save narrative'

    callback(null, narrative)

exports.createSection = (attributes, callback) ->
  if arguments.length == 1
    callback = attributes
    attributes = undefined

  section = new Section(attributes || content: "a section")

  section.save (err, section) ->
    if err?
      throw 'could not save section'

    callback(null, section)

exports.createIndicatorModels = (attributes) ->
  successCallback = errorCallback = promises = null

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

