mongoose = require('mongoose')
fs = require('fs')
Q = require('q')
crypto = require('crypto')

userSchema = mongoose.Schema(
  name: String
  email: String
  password: String
  salt: String
  distinguishedName: String
)

generateHash = (password, salt) ->
  deferred = Q.defer()

  theSalt = null

  Q.nsend(
    crypto, 'randomBytes', 32
  ).then( (buffer) ->

    if salt?
      theSalt = salt
    else
      theSalt = buffer.toString('hex')

    Q.nsend(
      crypto, 'pbkdf2',
      password, theSalt, 2000, 64
    )
  ).then( (buffer) ->

    hash = buffer.toString('hex')
    deferred.resolve(hash: hash, salt: theSalt)

  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

hashPassword = (next) ->
  user = @

  unless user.isModified('password')
    return next()

  generateHash(user.password).then( (hashComponents) ->

    user.password = hashComponents.hash
    user.salt = hashComponents.salt
    next()

  ).fail( (err) ->
    console.error err
    next(err)
  )

userSchema.pre('save', hashPassword)

userSchema.statics.seedData = (callback) ->
  return callback() if process.env.NODE_ENV is 'production'

  userAttributes = JSON.parse(
    fs.readFileSync("#{process.cwd()}/lib/users.json", 'UTF8')
  )

  User.count(null, (error, count) ->
    if error?
      console.error error
      return callback(error)

    if count == 0
      User.create(userAttributes, (error, results) ->
        if error?
          console.error error
          return callback(error)
        else
          return callback(null, results)
      )
    else
      callback()
  )

userSchema.methods.isValidPassword = (password) ->
  deferred = Q.defer()

  generateHash(password, @salt).then( (hashComponents) =>
    deferred.resolve(hashComponents.hash == @password)
  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

userSchema.methods.canEdit = (model) ->
  model.canBeEditedBy(@)

userSchema.methods.isLDAPAccount = ->
  return @distinguishedName?

userSchema.methods.loginFromLocalDb = (password, callback) ->
  @isValidPassword(password).then( (isValid) =>

    if isValid
      return callback(null, @)
    else
      throw new Error("Incorrect username or password")

  ).fail( (err) ->
    console.error err
    return callback(err, false)
  )

userSchema.methods.loginFromLDAP = (password, done) ->
  ldap = require('ldapjs')

  client = ldap.createClient(
    url: 'ldap://10.10.25.2:389'
  )

  client.bind(@distinguishedName, password, (err) =>
    if err?
      done(err, false)
    else
      done(null, @)
  )

userSchema.statics.fetchDistinguishedName = (username) ->
  deferred = Q.defer()

  ldap = require('ldapjs')
  client = ldap.createClient(
    url: 'ldap://10.10.25.2:389'
  )

  client.bind("CN=James Cox,OU=IntalioUsers,DC=esp,DC=ead,DC=ext", "Password.1", (err) =>
    if err?
      deferred.reject(err)
    else
      client.search(
        "OU=IntalioUsers,DC=esp,DC=ead,DC=ext",
        {
          filter:"(sAMAccountName=#{username})"
          scope: 'sub'
          attributes: ["distinguishedName"]
        },
        (err, search) ->
          search.on('searchEntry', (entry) ->
            deferred.resolve(entry.object.distinguishedName)
          )

          search.on('end', (result) ->
            if result.status > 0
              deferred.reject()
          )
      )
  )

  return deferred.promise

User = mongoose.model('User', userSchema)

module.exports = {
  schema: userSchema
  model: User
}
