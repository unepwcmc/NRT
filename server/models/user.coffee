mongoose = require('mongoose')
fs = require('fs')

userSchema = mongoose.Schema(
  name: String
  email: String
  password: String
)

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

userSchema.methods.validPassword = (password) ->
  @password == password

userSchema.methods.canEdit = (model) ->
  model.canBeEditedBy(@)

User = mongoose.model('User', userSchema)

module.exports = {
  schema: userSchema
  model: User
}
