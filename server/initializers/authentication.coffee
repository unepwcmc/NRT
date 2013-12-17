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

AppConfig = require('./config')

passport.use(
  new LocalStrategy(
    (username, password, done) ->
      Q.nsend(
        User.findOne(email: username), 'exec'
      ).then( (user) ->

        ldapEnabled = AppConfig.get('features').ldap

        if user?
          if ldapEnabled && user.isLDAPAccount()
            user.loginFromLDAP(password, done)
          else
            user.loginFromLocalDb(password, done)
        else
          if ldapEnabled
            User.createFromLDAPUsername(username)
              .then( (user) ->
                user.loginFromLDAP(password, done)
              ).fail( (err) ->
                message = User.KNOWN_LDAP_ERRORS[err?.name] ||
                  User.KNOWN_LDAP_ERRORS['InvalidCredentialsError']
                done(null, false, message: message)
              )
          else
            message = User.KNOWN_LDAP_ERRORS['InvalidCredentialsError']
            return done(null, false, message: message)

      ).fail( (err) ->
        done(null, false, {message: User.KNOWN_LDAP_ERRORS['OtherError']})
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
