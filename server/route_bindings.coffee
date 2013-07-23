narrativeApi = require('./routes/api/narrative')
indicatorRoutes = require('./routes/indicators.coffee')
reportRoutes = require('./routes/reports.coffee')
testRoutes = require('./routes/tests.coffee')


module.exports = exports = (app) ->
  # REST API
  app.resource 'api/narrative', narrativeApi, { format: 'json' }

  app.get "/", indicatorRoutes.index
  app.get "/indicators/", indicatorRoutes.index
  app.get "/indicator/:id", indicatorRoutes.show

  app.get "/report/:id", reportRoutes.show

  # Tests
  if app.settings.env == 'test'
    app.get "/tests", testRoutes.test
