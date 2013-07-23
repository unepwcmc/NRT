Sequelize = require("sequelize-mysql").sequelize

User = sequelize.define('User', {
  email:
    type: Sequelize.STRING
    allowNull: false
  password:
    type: Sequelize.STRING
    allowNull: false
  id:
    type: Sequelize.STRING
    primaryKey: true
  }, {
    instanceMethods:
      validPassword: (password) ->
        return @password == password
  }
)

User.sync()

module.exports = User
