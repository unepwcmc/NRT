passport = require('passport')
BasicStrategy = require('passport-http').BasicStrategy

passport.serializeUser (user, done) ->
  done(null, user.id)

passport.deserializeUser (id, done) ->
  User = require('../models/user').model
  User
    .find(id)
    .exec( (err, user) ->
      if err?
        console.error err
        return done(err)

      return done(null, user)
    )

passport.use(
  new BasicStrategy(
    (username, password, done) ->
      User = require('../models/user').model
      User.findOne({email: username}, (err, user) ->
        if err?
          console.error err
          return done(err)

        if !user
          return done(null, false, { message: 'Incorrect username.' })

        if !user.validPassword(password)
          return done(null, false, { message: 'Incorrect password.' })

        return done(null, user)
      )
  )
)

module.exports = passport
