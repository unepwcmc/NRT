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
          if user.isLDAPAccount()
            user.loginFromLDAP(password, done)
          else
            user.loginFromLocalDb(password, done)
        else
          User.fetchDistinguishedName(username)
            .then( (distinguishedName) ->

              user = new User(email: username, distinguishedName: distinguishedName)

              Q.nsend(
                user, 'save'
              )
            ).spread( (user) ->

              user.loginFromLDAP(password, done)

            ).fail( (err) ->
              console.log err
              done(null, false, {message: "Incorrect username or password"})
            )

      ).fail( (err) ->
        console.error err
        done(null, false, {message: err})
      )
  )
)

passport.addCurrentUserToLocals = (req, res, next) ->
  res.locals.currentUser = req.user
  next()

module.exports = passport
