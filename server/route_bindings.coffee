passport = require('./initializers/authentication')

narrativeApi = require('./routes/api/narrative')
visualisationApi = require('./routes/api/visualisation')
reportApi = require('./routes/api/report')
indicatorApi = require('./routes/api/indicator')

dashboardRoutes = require('./routes/dashboard.coffee')
indicatorRoutes = require('./routes/indicators.coffee')
localeRoutes    = require('./routes/locale.coffee')
reportRoutes    = require('./routes/reports.coffee')
userRoutes      = require('./routes/users.coffee')
staticRoutes    = require('./routes/static.coffee')
testRoutes      = require('./routes/tests.coffee')

module.exports = exports = (app) ->
  ensureAuthenticated = (req, res, next) ->
    return next() unless app.settings.env == 'production'

    passport.
      authenticate('basic').
      call(@, req, res, next)

  # REST API
  app.resource 'api/narratives', narrativeApi, { format: 'json' }
  app.resource 'api/visualisations', visualisationApi, { format: 'json' }
  app.resource 'api/reports', reportApi, { format: 'json' }
  app.resource 'api/indicators', indicatorApi, { format: 'json' }
  app.get "/api/indicators/:id/data", indicatorApi.data

  app.get "/", ensureAuthenticated, staticRoutes.about
  app.get "/dashboard", ensureAuthenticated, dashboardRoutes.index
  app.get "/indicators", ensureAuthenticated, indicatorRoutes.index
  app.get "/reports", ensureAuthenticated, reportRoutes.index

  app.get "/indicators/:id", ensureAuthenticated, indicatorRoutes.show

  app.get "/reports/new", ensureAuthenticated, reportRoutes.new
  app.get "/reports/:id", ensureAuthenticated, reportRoutes.show
  app.get "/reports/:id/present", ensureAuthenticated, reportRoutes.present

  app.get "/locale/:locale", ensureAuthenticated, localeRoutes.index

  ## Tests
  if app.settings.env == 'test'
    app.get "/tests", testRoutes.test

  ## User CRUD
  ## express-resource doesn't support using middlewares
  useTokenAuthentication = require('./lib/token_authentication.coffee')

  app.get "/users", useTokenAuthentication, userRoutes.index
  app.get "/users/:id", useTokenAuthentication, userRoutes.show

  app.post "/users", useTokenAuthentication, userRoutes.create
  app.delete "/users/:id", useTokenAuthentication, userRoutes.destroy
