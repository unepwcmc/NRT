passport = require('passport')
_ = require('underscore')
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
          if user.isLDAPAccount()
            user.loginFromLDAP(password, done)
          else
            user.loginFromLocalDb(password, done)
        else
          User.createFromLDAPUsername(username)
            .then( (user) ->
              user.loginFromLDAP(password, done)
            ).fail( (err) ->
              done(null, false, {message: "Incorrect username or password"})
            )

      ).fail( (err) ->
        console.error err
        done(null, false, {message: err})
      )
  )
)

userValueBlacklist = ['password', 'salt']
stripSensitiveDataFromUser = (user) ->
  _.omit(user.toJSON(), userValueBlacklist)

passport.addCurrentUserToLocals = (req, res, next) ->
  if req.user?
    user = stripSensitiveDataFromUser(req.user)

    res.locals.currentUser = user
    res.locals.currentUserJSON = JSON.stringify(user)

  next()

module.exports = passport
