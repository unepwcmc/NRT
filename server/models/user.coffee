mongoose = require('mongoose')
fs = require('fs')
bcrypt = require('bcrypt')
Q = require('q')

userSchema = mongoose.Schema(
  name: String
  email: String
  password: String
)

hashPassword = (next) ->
  user = @

  unless user.isModified('password')
    return next()

  bcrypt.genSalt(5, (err, salt) ->
    if err?
      console.log err
      return next(err)

    bcrypt.hash(user.password, salt, (err, hash) ->
      if err?
        console.log err
        return next(err)

      user.password = hash
      next()
    )
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

  bcrypt.compare(password, @password, (err, matched) ->
    if err?
      deferred.reject(err)

    deferred.resolve(matched)
  )

  return deferred.promise

userSchema.methods.canEdit = (model) ->
  model.canBeEditedBy(@)

User = mongoose.model('User', userSchema)

module.exports = {
  schema: userSchema
  model: User
}
