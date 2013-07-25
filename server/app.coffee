express = require("express")
hbs = require('express-hbs')
http = require('http')
path = require('path')
lessMiddleware = require('less-middleware')
require('express-resource')
sass = require('node-sass')
passport = require('passport')


exports.createApp = ->
  app = express()

  sequelize = require('./model_bindings.coffee')(app.get('env'))
  GLOBAL.sequelize = sequelize
  bindRoutesForApp = require('./route_bindings.coffee')

  # assign the handlebars engine to .html files
  app.engine "hbs", hbs.express3(
    partialsDir: __dirname + '/views/partials'
    layoutsDir: __dirname + '/views/layouts'
  )
  app.set "view engine", "hbs"
  app.set "views", __dirname + "/views"

  app.use passport.initialize()
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("your secret here")
  app.use express.session()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

  app.use express.errorHandler()  if "development" is app.get("env")

  bindRoutesForApp(app)
  app

exports.start = (port, callback) ->
  app = exports.createApp()
  server = http.createServer(app).listen port, (err) ->
      callback err, server
