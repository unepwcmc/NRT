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

loginFromLDAP = (username, password, done) ->
  return done(null, false)

passport.use(
  new LocalStrategy(
    (username, password, done) ->
      if User.isLDAPAccount(username)
        strategy = loginFromLDAP
      else
        strategy = User.loginFromLocalDb

      strategy.apply(@, arguments)
  )
)

passport.addCurrentUserToLocals = (req, res, next) ->
  res.locals.currentUser = req.user
  next()

module.exports = passport
