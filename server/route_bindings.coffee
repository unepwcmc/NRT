passport = require('./initializers/authentication')

sectionApi = require('./routes/api/section')
narrativeApi = require('./routes/api/narrative')
visualisationApi = require('./routes/api/visualisation')
reportApi = require('./routes/api/report')

dashboardRoutes = require('./routes/dashboard.coffee')
indicatorRoutes = require('./routes/indicators.coffee')
bookmarkRoutes  = require('./routes/bookmarks.coffee')
reportRoutes    = require('./routes/reports.coffee')
userRoutes      = require('./routes/users.coffee')
testRoutes      = require('./routes/tests.coffee')

module.exports = exports = (app) ->
  ensureAuthenticated = (req, res, next) ->
    return next() unless app.settings.env == 'production'

    passport.
      authenticate('basic').
      call(@, req, res, next)

  # REST API
  app.resource 'api/narrative', narrativeApi, { format: 'json' }
  app.resource 'api/visualisation', visualisationApi, { format: 'json' }
  app.resource 'api/report', reportApi, { format: 'json' }
  app.resource 'api/section', sectionApi, { format: 'json' }

  app.get "/", ensureAuthenticated, dashboardRoutes.index
  app.get "/dashboard", ensureAuthenticated, dashboardRoutes.index
  app.get "/indicators", ensureAuthenticated, indicatorRoutes.index
  app.get "/reports", ensureAuthenticated, reportRoutes.index
  app.get "/bookmarks", ensureAuthenticated, bookmarkRoutes.index

  app.get "/indicators/:id", ensureAuthenticated, indicatorRoutes.show

  app.get "/reports/new", ensureAuthenticated, reportRoutes.new
  app.get "/reports/:id", ensureAuthenticated, reportRoutes.show
  app.get "/reports/:id/present", ensureAuthenticated, reportRoutes.present

  # Tests
  if app.settings.env == 'test'
    app.get "/tests", testRoutes.test

  # User CRUD
  # express-resource doesn't support using middlewares
  useTokenAuthentication = require('./lib/token_authentication.coffee')

  app.get "/users", useTokenAuthentication, userRoutes.index
  app.get "/users/:id", useTokenAuthentication, userRoutes.show

  app.post "/users", useTokenAuthentication, userRoutes.create
  app.delete "/users/:id", useTokenAuthentication, userRoutes.destroy
