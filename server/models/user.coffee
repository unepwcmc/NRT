mongoose = require('mongoose')

userSchema = mongoose.Schema(
  email: String
  password: String
)

userSchema.methods.validPassword = (password) ->
  @password == password

User = mongoose.model('User', userSchema)

module.exports = {
  schema: userSchema
  model: User
}
