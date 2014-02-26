_ = require('underscore')

passport = require('./initializers/authentication')
tokenAuthentication = require('./lib/token_authentication')
sessionAuthentication = require('./lib/session_authentication')

visualisationApi = require('./controllers/api/visualisation')
narrativeApi     = require('./controllers/api/narrative')
indicatorApi     = require('./controllers/api/indicator')
reportApi        = require('./controllers/api/report')
themeApi         = require('./controllers/api/theme')
pageApi          = require('./controllers/api/page')
userApi          = require('./controllers/api/user')

dashboardRoutes = require('./controllers/dashboard')
indicatorRoutes = require('./controllers/indicators')
sessionRoutes   = require('./controllers/session')
deployRoutes    = require('./controllers/deploy')
localeRoutes    = require('./controllers/locale')
reportRoutes    = require('./controllers/reports')
staticRoutes    = require('./controllers/static')
adminRoutes     = require('./controllers/admin')
themeRoutes     = require('./controllers/themes')
testRoutes      = require('./controllers/tests')

module.exports = exports = (app) ->
  app.use('/', sessionAuthentication)
  app.use('/api/users', tokenAuthentication)

  app.use passport.addCurrentUserToLocals

  app.get "/login", sessionRoutes.login
  app.get "/logout", sessionRoutes.logout
  app.post '/login', passport.authenticate('local', {
    failureRedirect: '/login',
    failureFlash: true
  }), sessionRoutes.loginSuccess

  # REST API
  app.resource 'api/narratives', narrativeApi, { format: 'json' }
  app.resource 'api/visualisations', visualisationApi, { format: 'json' }
  app.resource 'api/reports', reportApi, { format: 'json' }
  app.resource 'api/themes', themeApi, { format: 'json' }
  app.get "/api/themes/:id/fat", themeApi.fatShow
  app.resource 'api/indicators', indicatorApi, { format: 'json' }
  app.resource 'api/pages', pageApi, { format: 'json' }
  app.get "/api/indicators/:id/fat", indicatorApi.fatShow
  app.get "/api/indicators/:id/headlines", indicatorApi.headlines
  app.get "/api/indicators/:id/headlines/:count", indicatorApi.headlines
  app.get "/api/indicators/:id/data", indicatorApi.data
  app.get "/api/indicators/:id/data.csv", indicatorApi.dataAsCSV

  ## User CRUD
  ## express-resource doesn't support using middlewares
  app.get "/api/users", userApi.index
  app.get "/api/users/:id", userApi.show
  app.post "/api/users", userApi.create
  app.delete "/api/users/:id", userApi.destroy

  app.get "/", themeRoutes.index
  app.get "/about", staticRoutes.about
  app.get "/architecture", staticRoutes.architecture
  app.get "/partners", staticRoutes.partners

  app.get "/dashboard", dashboardRoutes.index
  app.get "/themes", themeRoutes.index
  app.get "/reports", reportRoutes.index

  app.get "/indicators/:id", indicatorRoutes.show
  app.get "/indicators/:id/draft", indicatorRoutes.show
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
  app.get "/locales/en-:locale.json", localeRoutes.redirect

  app.post "/deploy", deployRoutes.index

  ## Tests
  unless app.settings.env == 'production'
    app.get "/tests", testRoutes.test

  app.get "/admin/updateIndicatorData/:id", adminRoutes.updateIndicatorData
  app.get "/admin/updateAll", adminRoutes.updateAll
  app.get "/admin", adminRoutes.updateAll
  app.get "/admin/seedIndicatorData", adminRoutes.seedIndicatorData
