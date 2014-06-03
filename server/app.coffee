fs = require('fs')
express = require('express')
hbs = require('express-hbs')
http = require('http')
path = require('path')
require('express-resource')
passport = require('passport')
mongoose = require('mongoose')
MongoStore = require('connect-mongo')(express)
appConfig = require('./initializers/config')
i18n = require('i18n')
flash = require('connect-flash')
Promise = require('bluebird')


exports.createApp = ->
  app = express()

  if app.get('env') isnt 'production'
    require('bluebird').longStackTraces()
    require('q').longStackSupport = true

  require('./initializers/logging')(app)

  app.use appConfig.initialize()

  require('./initializers/mongo')()

  bindRoutesForApp = require('./route_bindings.coffee')

  if app.get('env') isnt 'production'
    sass = require('node-sass')
    app.use sass.middleware(
      src: path.join(__dirname, "..", "client", "src")
      dest: path.join(__dirname, 'public')
      debug: true
    )

    coffee = require('coffee-middleware')
    app.use coffee(
      src: path.join(__dirname, "public")
      compress: true
      force: true
      debug: true
      encodeSrc: false
    )

  app.use express.compress()

  maxAge = -1
  if app.get('env') is 'production'
    oneWeekInMilliseconds = (60 * 60 * 24 * 7) * 1000
    oneYearInMilliseconds = oneWeekInMilliseconds * 52
    maxAge = oneYearInMilliseconds
  app.use express.static(path.join(__dirname, "public"), maxAge: maxAge)

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
      maxAge: oneWeekInMilliseconds
    )
  )
  app.use flash()

  require('./initializers/i18n')(app)

  app.use passport.initialize()
  app.use passport.session()

  bindRoutesForApp(app)

  app

exports.start = (callback) ->
  app = exports.createApp()

  seedData() unless app.get('env') is "test"
  port = retrievePort()

  # replace default umask with 0000 and save
  # original umask
  defaultProcessUmask = process.umask(0o000)

  server = http.createServer(app).listen(port, (err) ->
    # reset umask
    process.umask(defaultProcessUmask)

    callback(err, server, port)
  )

  return app

retrievePort = ->
  serverConfig = appConfig.get('server') or {}

  if serverConfig.use_unix_sockets
    socketPath = "/tmp/#{serverConfig.name}.sock"

    fs.unlinkSync(socketPath) if fs.existsSync(socketPath)
    return socketPath
  else
    return serverConfig.port || process.env.PORT || 3000

seedData = ->
  Theme = require("./models/theme").model
  Indicator = require("./models/indicator").model
  IndicatorData = require("./models/indicator_data").model

  themeSeedsPath = "#{process.cwd()}/config/seeds/themes.json"
  indicatorSeedsPath = "#{process.cwd()}/config/seeds/indicators.json"

  Promise.join(
    Promise.promisify(Theme.count, Theme)(null),
    Promise.promisify(Indicator.count, Indicator)(null)
  ).spread( (themesCount, indicatorsCount) ->
    seedingPromise = Promise.resolve()
    if themesCount == 0
      seedingPromise = seedingPromise.then(Theme.seedData(themeSeedsPath))
    if indicatorsCount == 0
      seedingPromise = seedingPromise.then(Indicator.seedData(indicatorSeedsPath))
  ).catch( (err) ->
    console.log "error seeding indicator data:"
    console.error err
    console.error err.stack
    throw err
  )

  User = require("./models/user").model
  User.seedData(->)
