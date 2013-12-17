fs = require('fs')
path = require('path')
_ = require('underscore')

APP_CONFIG = null

exports.get = (key) ->
  if APP_CONFIG?
    _.clone(APP_CONFIG[key])
  else
    throw new Error("No application config found, have you called AppConfig.initialize() first?")

getEnv = ->
  unless process.env.NODE_ENV?
    return 'development'

  return process.env.NODE_ENV

exports.initialize = ->
  env = getEnv()

  configFile = path.join(__dirname, '../', 'config', "#{env}.json")

  unless fs.existsSync(configFile)
    throw new Error(
      "No config for env in #{configFile}, copy config/env.json.example and edit as appropriate"
    )

  configJSON = fs.readFileSync(configFile)
  APP_CONFIG = JSON.parse(configJSON)

  middleware = (req, res, next) ->
    req.APP_CONFIG = res.locals.APP_CONFIG = APP_CONFIG

    next()

  return middleware
