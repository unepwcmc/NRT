passportStub = require 'passport-stub'
app = require('../app')
test_server = null
url = require('url')
mongoose = require('mongoose')
factory = require('./factory')
async = require('async')

before( (done) ->
  expressApp = app.start((err, server) ->
    test_server = server
    done()
  )
  passportStub.install expressApp
)

after( (done) ->
  test_server.close (err) ->
    if err?
      console.error err

    done()
)

afterEach( ->
  passportStub.logout()
)

dropDatabase = (connection, done) ->
  models = [
    "report",
    "indicator",
    "indicator_data",
    "narrative",
    "section",
    "visualisation",
    "theme",
    "page",
    "user",
    "permission"
  ]

  removeTable = (table, callback) ->
    table = require("../models/#{table}").model
    table
      .remove()
      .exec(callback)

  async.each(models, removeTable, (err) ->
    if err?
      console.error 'Could not clean database'

    done()
  )

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

exports.createReport = factory.defineWithCallback("report", title: 'new report')
exports.createIndicator = factory.defineWithCallback("indicator", name: 'new indicator')
exports.createVisualisation = factory.defineWithCallback("visualisation", data: 'new viz')
exports.createNarrative = factory.defineWithCallback("narrative", content: 'new narrative')
exports.createSection = factory.defineWithCallback("section", title: 'a section')

exports.createIndicatorData = factory.define("indicator_data", data: 'data')
exports.createIndicatorModels = factory.define("indicator", title: "new report")
exports.createReportModels = factory.define("report", title: "new report")
exports.createThemesFromAttributes = factory.define("theme", title: "new theme")
exports.createUser = factory.define("user",
  email: "hats@boats.com"
  password: "yomamalikeshats"
)
exports.createTheme = factory.define("theme", title: "new theme")
exports.createPage = factory.define("page", title: "new page")
