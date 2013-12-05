passport = require('passport')
LocalStrategy = require('passport-local').Strategy
Q = require('q')
User = require('../models/user').model

passport.serializeUser (user, done) ->
  done(null, user._id)

passport.deserializeUser (id, done) ->
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
      Q.nsend(
        User.findOne(email: username), 'exec'
      ).then( (user) ->

        if user?
          user.loginFromLocalDb(password, done)
        else
          done(null, false, {message: "Incorrect username or password"})

      ).fail( (err) ->
        console.error err
        done(null, false, {message: err})
      )
  )
)

passport.addCurrentUserToLocals = (req, res, next) ->
  if req.user?
    res.locals.currentUser= req.user
    res.locals.currentUserJSON = JSON.stringify(req.user)
  next()

module.exports = passport
