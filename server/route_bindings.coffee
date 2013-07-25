passport = require('./initializers/authentication')

sectionApi = require('./routes/api/section')
narrativeApi = require('./routes/api/narrative')
dashboardRoutes = require('./routes/dashboard.coffee')
indicatorRoutes = require('./routes/indicators.coffee')
bookmarkRoutes = require('./routes/bookmarks.coffee')
reportRoutes = require('./routes/reports.coffee')
testRoutes = require('./routes/tests.coffee')

module.exports = exports = (app) ->
  ensureAuthenticated = (req, res, next) ->
    return next() unless app.settings.env == 'production'

    passport.
      authenticate('basic', { session: false }).
      call(@, req, res, next)

  # REST API
  app.resource 'api/narrative', narrativeApi, { format: 'json' }
  app.resource 'api/section', sectionApi, { format: 'json' }

  app.get "/", ensureAuthenticated, dashboardRoutes.index
  app.get "/dashboard", ensureAuthenticated, dashboardRoutes.index
  app.get "/indicators", ensureAuthenticated, indicatorRoutes.index
  app.get "/reports", ensureAuthenticated, reportRoutes.index
  app.get "/bookmarks", ensureAuthenticated, bookmarkRoutes.index

  app.get "/indicator/:id", ensureAuthenticated, indicatorRoutes.show

  app.get "/report/:id", ensureAuthenticated, reportRoutes.show

  # Tests
  if app.settings.env == 'test'
    app.get "/tests", testRoutes.test
