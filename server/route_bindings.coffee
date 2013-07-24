passport = require('./initializers/authentication')

narrativeApi = require('./routes/api/narrative')
dashboardRoutes = require('./routes/dashboard.coffee')
indicatorRoutes = require('./routes/indicators.coffee')
bookmarkRoutes = require('./routes/bookmarks.coffee')
reportRoutes = require('./routes/reports.coffee')
testRoutes = require('./routes/tests.coffee')

module.exports = exports = (app) ->
  # REST API
  app.resource 'api/narrative', narrativeApi, { format: 'json' }

  app.get "/", dashboardRoutes.index
  app.get "/dashboard", dashboardRoutes.index
  app.get "/indicators", indicatorRoutes.index
  app.get "/reports", reportRoutes.index
  app.get "/bookmarks", bookmarkRoutes.index

  app.get "/indicator/:id", indicatorRoutes.show

  app.get "/report/:id", reportRoutes.show

  # Tests
  if app.settings.env == 'test'
    app.get "/tests", testRoutes.test
