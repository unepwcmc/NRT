express = require("express")
hbs = require('express-hbs')
http = require('http')
path = require('path')
lessMiddleware = require('less-middleware')
require('express-resource')
passport = require('passport')
mongoose = require('mongoose')
i18n = require('i18n')

exports.createApp = ->
  app = express()

  mongoose.connect("mongodb://localhost/nrt_#{app.get('env')}")

  bindRoutesForApp = require('./route_bindings.coffee')

  # assign the handlebars engine to .html files
  app.engine "hbs", hbs.express3(
    partialsDir: __dirname + '/views/partials'
    layoutsDir: __dirname + '/views/layouts'
  )
  app.set "view engine", "hbs"
  app.set "views", __dirname + "/views"

  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("your secret here")
  app.use express.session()

  require('./initializers/logging')(app)

  require('./initializers/i18n')(app)

  app.use passport.initialize()
  app.use passport.session()

  app.use app.router

  app.use express.static(path.join(__dirname, "public"))
  app.use express.errorHandler()  if "development" is app.get("env")

  bindRoutesForApp(app)
  app

exports.start = (port, callback) ->
  app = exports.createApp()

  seedData()

  server = http.createServer(app).listen port, (err) ->
      callback err, server

  return app

seedData = ->
  Indicator = require("./models/indicator").model
  Indicator.seedData(->)

  IndicatorData = require("./models/indicator_data").model
  IndicatorData.seedData(->)

  Theme = require("./models/theme").model
  Theme.seedData(->)

  User = require("./models/user").model
  User.seedData(->)
