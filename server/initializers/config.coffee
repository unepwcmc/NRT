fs = require('fs')

module.exports = (app) ->
  configJSON = fs.readFileSync("../config/#{app.get('env')}.json")
  config     = JSON.parse(configJSON)

  middleware = (req, res, next) ->
    req.APP_CONFIG = res.locals.APP_CONFIG = config

    next()

  app.use(middleware)
