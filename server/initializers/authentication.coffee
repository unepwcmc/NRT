passport = require('passport')
LocalStrategy = require('passport-local').Strategy
Q = require('q')

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
  new LocalStrategy(
    (username, password, done) ->
      User = require('../models/user').model

      theUser = null

      Q.nsend(
        User.findOne({email: username}), 'exec'
      ).then( (user) ->
        theUser = user

        if !user
          return done(null, false, { message: 'Incorrect username.' })

        user.isValidPassword(password)

      ).then( (isValid) ->

          if isValid
            return done(null, theUser)
          else
            return done(null, false, { message: 'Incorrect password.' })

      ).fail( (err) ->
        console.error err
        done(err, false)
      )
  )
)

passport.addCurrentUserToLocals = (req, res, next) ->
  res.locals.currentUser = req.user
  next()

module.exports = passport
