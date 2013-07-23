passport = require('passport')
BasicStrategy = require('passport-http').BasicStrategy

narrativeApi = require('./routes/api/narrative')
indicatorRoutes = require('./routes/indicators.coffee')
reportRoutes = require('./routes/reports.coffee')
testRoutes = require('./routes/tests.coffee')

module.exports = exports = (app) ->
  passport.use(
    new BasicStrategy(
      (username, password, done) ->
        User = require('./models/user')

        User.find(where: {email: username}).success((user) ->
          if !user
            return done(null, false, { message: 'Incorrect username.' })

          if !user.validPassword(password)
            return done(null, false, { message: 'Incorrect password.' })

          return done(null, user)
        ).failure((error) ->
          return done(null, false)
        )
    )
  )

  # REST API
  app.resource 'api/narrative', narrativeApi, { format: 'json' }

  app.get "/", passport.authenticate('basic', { session: false }), indicatorRoutes.index
  app.get "/indicators/", passport.authenticate('basic', { session: false }), indicatorRoutes.index

  app.get "/indicator/:id", indicatorRoutes.show

  app.get "/report/:id", reportRoutes.show

  # Tests
  if app.settings.env == 'test'
    app.get "/tests", testRoutes.test
