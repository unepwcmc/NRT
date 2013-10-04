passport = require('passport')
BasicStrategy = require('passport-http').BasicStrategy

passport.serializeUser (user, done) ->
  done(null, user._id)

passport.deserializeUser (id, done) ->
  User = require('../models/user').model

  unless id?
    console.error 'No user ID supplied'
    return done(err, false)

  User
    .findOne(_id: id)
    .exec( (err, user) ->
      if err?
        console.error err
        return done(err, false)

      return done(null, user)
    )

passport.use(
  new BasicStrategy(
    (username, password, done) ->
      User = require('../models/user').model
      User.findOne({email: username}, (err, user) ->
        if err?
          console.error err
          return done(err, false)

        if !user
          return done(null, false, { message: 'Incorrect username.' })

        if !user.validPassword(password)
          return done(null, false, { message: 'Incorrect password.' })

        return done(null, user)
      )
  )
)

passport.addCurrentUserToLocals = (req, res, next) ->
  res.locals.currentUser = req.user
  next()

module.exports = passport
