fs = require('fs')
path = require('path')
_ = require('underscore')

APP_CONFIG = null

exports.get = (key) ->
  if APP_CONFIG?
    _.clone(APP_CONFIG[key])
  else
    throw new Error("No AppConfig found, have you called AppConfig.initialize() first?")

exports.initialize = (app) ->
  configFile = path.join(__dirname, '../', 'config', "#{app.get('env')}.json")

  unless fs.existsSync(configFile)
    throw new Error(
      "No config for env in #{configFile}, copy config/env.json.example and edit as appropriate"
    )

  configJSON = fs.readFileSync(configFile)
  APP_CONFIG = JSON.parse(configJSON)

  middleware = (req, res, next) ->
    req.APP_CONFIG = res.locals.APP_CONFIG = APP_CONFIG

    next()

  app.use(middleware)
