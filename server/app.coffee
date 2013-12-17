express = require("express")
hbs = require('express-hbs')
http = require('http')
path = require('path')
require('express-resource')
passport = require('passport')
mongoose = require('mongoose')
MongoStore = require('connect-mongo')(express)
AppConfig = require('./initializers/config')
i18n = require('i18n')
flash = require('connect-flash')

exports.createApp = ->
  app = express()

  require('./initializers/logging')(app)
  AppConfig.initialize(app)
  require('./initializers/mongo')(app.get('env'))

  bindRoutesForApp = require('./route_bindings.coffee')

  app.use express.static(path.join(__dirname, "public"))

  app.engine "hbs", hbs.express3(
    partialsDir: __dirname + '/views/partials'
    layoutsDir: __dirname + '/views/layouts'
  )
  app.set "view engine", "hbs"
  app.set "views", __dirname + "/views"
  require('./initializers/handlebars_helpers')

  app.use express.favicon()

  app.use express.json()
  app.use express.urlencoded()
  app.use express.methodOverride()

  app.use express.cookieParser("your secret here")
  app.use express.session(
    store: new MongoStore(
      url: "mongodb://localhost/nrt_#{app.get('env')}"
      maxAge: 300000
    )
  )
  app.use(flash())

  require('./initializers/i18n')(app)

  app.use passport.initialize()
  app.use passport.session()

  bindRoutesForApp(app)

  app

exports.start = (port, callback) ->
  app = exports.createApp()

  seedData() unless app.get('env') is "test"

  server = http.createServer(app).listen port, (err) ->
    callback err, server

  return app

seedData = ->
  Theme = require("./models/theme").model
  Indicator = require("./models/indicator").model
  IndicatorData = require("./models/indicator_data").model

  Theme.seedData()
  .then(Indicator.seedData)
  .fail((err) ->
    console.log "error seeding indicator data:"
    console.error err
    console.error err.stack
    throw err
  )

  User = require("./models/user").model
  User.seedData(->)
