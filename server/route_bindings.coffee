_ = require('underscore')

passport = require('./initializers/authentication')
tokenAuthentication = require('./lib/token_authentication')

visualisationApi = require('./routes/api/visualisation')
narrativeApi     = require('./routes/api/narrative')
indicatorApi     = require('./routes/api/indicator')
reportApi        = require('./routes/api/report')
themeApi         = require('./routes/api/theme')
pageApi          = require('./routes/api/page')
userApi          = require('./routes/api/user')

dashboardRoutes = require('./routes/dashboard')
indicatorRoutes = require('./routes/indicators')
localeRoutes    = require('./routes/locale')
reportRoutes    = require('./routes/reports')
staticRoutes    = require('./routes/static')
adminRoutes     = require('./routes/admin')
themeRoutes     = require('./routes/themes')
testRoutes      = require('./routes/tests')

module.exports = exports = (app) ->
  ensureAuthenticated = (req, res, next) ->
    return next() if app.settings.env is 'test'

    authMethod = passport.authenticate('basic')

    # Secure the user API with an auth token
    if _.contains(["POST", "DELETE"], req.method) and req.path.match(/^\/api\/users/)?
      authMethod = tokenAuthentication

    authMethod.call(@, req, res, next)

  app.use passport.addCurrentUserToLocals
  app.all('*', ensureAuthenticated)

  # REST API
  app.resource 'api/narratives', narrativeApi, { format: 'json' }
  app.resource 'api/visualisations', visualisationApi, { format: 'json' }
  app.resource 'api/reports', reportApi, { format: 'json' }
  app.resource 'api/themes', themeApi, { format: 'json' }
  app.resource 'api/indicators', indicatorApi, { format: 'json' }
  app.resource 'api/pages', pageApi, { format: 'json' }
  app.resource 'api/users', userApi, { format: 'json' }
  app.get "/api/indicators/:id/headlines", indicatorApi.headlines
  app.get "/api/indicators/:id/headlines/:count", indicatorApi.headlines
  app.get "/api/indicators/:id/data", indicatorApi.data
  app.get "/api/indicators/:id/data.csv", indicatorApi.dataAsCSV

  app.get "/", themeRoutes.index
  app.get "/about", staticRoutes.about
  app.get "/dashboard", dashboardRoutes.index
  app.get "/themes", themeRoutes.index
  app.get "/indicators", indicatorRoutes.index
  app.get "/reports", reportRoutes.index

  app.get "/indicators/:id", indicatorRoutes.show
  app.get "/indicators/:id/draft", indicatorRoutes.showDraft
  app.get "/indicators/:id/discard_draft", indicatorRoutes.discardDraft
  app.get "/indicators/:id/publish", indicatorRoutes.publishDraft
  app.get "/themes/:id", themeRoutes.show
  app.get "/themes/:id/draft", themeRoutes.showDraft
  app.get "/themes/:id/discard_draft", themeRoutes.discardDraft
  app.get "/themes/:id/publish", themeRoutes.publishDraft

  app.get "/reports/new", reportRoutes.new
  app.get "/reports/:id", reportRoutes.show
  app.get "/reports/:id/present", reportRoutes.present

  app.get "/locale/:locale", localeRoutes.index

  ## Tests
  unless app.settings.env == 'production'
    app.get "/tests", testRoutes.test

  app.get "/admin/updateIndicatorData/:id", adminRoutes.updateIndicatorData
  app.get "/admin/updateAll", adminRoutes.updateAll
  app.get "/admin", adminRoutes.updateAll
