indicatorsRoutes = require('./routes/indicators.coffee')

console.log indicatorsRoutes

module.exports = exports = (app) ->
  app.get "/", indicatorsRoutes.show