Sequelize = require("sequelize-mysql").sequelize

Indicator = sequelize.define('Indicator',
  id:
    type: Sequelize.INTEGER
    primaryKey: true
  title:
    type: Sequelize.TEXT
    allowNull: false
)

Indicator.sync()

module.exports = Indicator
