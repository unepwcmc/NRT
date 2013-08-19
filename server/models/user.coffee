mongoose = require('mongoose')

userSchema = mongoose.Schema(
  email: String
  password: String
)

User = mongoose.model('User', userSchema)

module.exports = {
  schema: userSchema
  model: User
}
