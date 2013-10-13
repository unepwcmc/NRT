passportStub = require 'passport-stub'
app = require('../app')
test_server = null
url = require('url')
mongoose = require('mongoose')
_ = require('underscore')
async = require('async')
Q = require('q')
factory = require('./factory')

Section = require('../models/section').model
Report = require('../models/report').model
Indicator = require('../models/indicator').model
IndicatorData = require('../models/indicator_data').model
Visualisation = require('../models/visualisation').model
Narrative = require('../models/narrative').model
Theme = require('../models/theme').model
Page = require('../models/page').model
User = require('../models/user').model
Permission = require('../models/permission').model

before( (done) ->
  expressApp = app.start 3001, (err, server) ->
    test_server = server
    done()
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
    Report,
    Indicator,
    IndicatorData,
    Narrative,
    Section,
    Visualisation,
    Theme,
    Page,
    User,
    Permission
  ]

  for model in models
    model
      .remove()
      .exec()

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

exports.createReport = factory.defineWithCallback("report", title: 'new report')
exports.createIndicator = factory.defineWithCallback("indicator", title: 'new indicator')
exports.createIndicatorData = factory.defineWithCallback("indicator_data", data: 'data')
exports.createVisualisation = factory.defineWithCallback("visualisation", data: 'new viz')
exports.createNarrative = factory.defineWithCallback("narrative", content: 'new narrative')
exports.createSection = factory.defineWithCallback("section", title: 'a section')

exports.createIndicatorModels = factory.define("indicator", title: "new report")
exports.createReportModels = factory.define("report", title: "new report")
exports.createThemesFromAttributes = factory.define("theme", title: "new theme")
exports.createUser = factory.define("user",
  email: "hats@boats.com"
  password: "yomamalikeshats"
)
exports.createTheme = factory.define("theme", title: "new theme")
exports.createPage = factory.define("page", title: "new page")
