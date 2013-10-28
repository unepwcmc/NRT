express = require("express")
hbs = require('express-hbs')
http = require('http')
path = require('path')
require('express-resource')
passport = require('passport')
mongoose = require('mongoose')
MongoStore = require('connect-mongo')(express)
i18n = require('i18n')

exports.createApp = ->
  app = express()

  mongoose.connect("mongodb://localhost/nrt_#{app.get('env')}")

  bindRoutesForApp = require('./route_bindings.coffee')

  require('./initializers/logging')(app)
  app.use express.static(path.join(__dirname, "public"))

  # assign the handlebars engine to .html files
  app.engine "hbs", hbs.express3(
    partialsDir: __dirname + '/views/partials'
    layoutsDir: __dirname + '/views/layouts'
  )
  app.set "view engine", "hbs"
  app.set "views", __dirname + "/views"
  require('./initializers/handlebars_helpers')

  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("your secret here")
  app.use express.session(
    store: new MongoStore(
      url: "mongodb://localhost/nrt_#{app.get('env')}"
      maxAge: 300000
    )
  )

  require('./initializers/i18n')(app)

  app.use passport.initialize()
  app.use passport.session()

  bindRoutesForApp(app)

  app

exports.start = (port, callback) ->
  app = exports.createApp()

  seedData()

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
