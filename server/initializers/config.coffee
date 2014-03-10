fs = require('fs')
path = require('path')
_ = require('underscore')

APP_CONFIG = null

exports.get = (key) ->
  unless APP_CONFIG?
    APP_CONFIG = readConfigFile()

  _.clone(APP_CONFIG[key])

getEnv = ->
  process.env.NODE_ENV || 'development'

readConfigFile = ->
  env = getEnv()

  configFile = path.join(__dirname, '../', 'config', "#{env}.json")

  unless fs.existsSync(configFile)
    throw new Error(
      "No config for env in #{configFile}, copy config/env.json.example and edit as appropriate"
    )

  configJSON = fs.readFileSync(configFile)
  return JSON.parse(configJSON)

exports.initialize = ->
  readConfigFile()

  middleware = (req, res, next) ->
    req.APP_CONFIG = res.locals.APP_CONFIG = APP_CONFIG

    next()

  return middleware
