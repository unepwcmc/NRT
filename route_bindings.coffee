indicatorRoutes = require('./routes/indicators.coffee')
reportRoutes = require('./routes/reports.coffee')

console.log indicatorRoutes

module.exports = exports = (app) ->
  app.get "/", indicatorRoutes.index
  app.get "/indicators/", indicatorRoutes.index

  app.get "/indicator/:id", indicatorRoutes.show

  app.get "/report/:id", reportRoutes.show
