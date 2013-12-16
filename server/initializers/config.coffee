fs = require('fs')
path = require('path')

module.exports = (app) ->
  configFile = path.join(__dirname, '../', 'config', "#{app.get('env')}.json")

  unless fs.existsSync(configFile)
    throw new Error(
      "No config for env in #{configFile}, copy config/env.json.example and edit as appropriate"
    )

  configJSON = fs.readFileSync(configFile)
  config     = JSON.parse(configJSON)

  middleware = (req, res, next) ->
    req.APP_CONFIG = res.locals.APP_CONFIG = config

    next()

  app.use(middleware)
