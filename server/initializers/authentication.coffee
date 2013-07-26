passport = require('passport')
BasicStrategy = require('passport-http').BasicStrategy

passport.serializeUser (user, done) ->
  done(null, user.id)

passport.deserializeUser (id, done) ->
  User = require('../models/user')
  User.find(id).
    success( (user) ->
      done(null, user)
    ).
    failure( (err) ->
      done(err)
    )

passport.use(
  new BasicStrategy(
    (username, password, done) ->
      User = require('../models/user')
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

module.exports = passport
