fs = require('fs')
path = require('path')

module.exports = (app) ->
  configDir = path.join(__dirname, '../', 'config')
  configJSON = fs.readFileSync("#{configDir}/#{app.get('env')}.json")
  config     = JSON.parse(configJSON)

  middleware = (req, res, next) ->
    req.APP_CONFIG = res.locals.APP_CONFIG = config

    next()

  app.use(middleware)
