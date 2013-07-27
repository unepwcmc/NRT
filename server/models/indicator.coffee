Sequelize = require("sequelize-mysql").sequelize

Indicator = sequelize.define('Indicator',
  id:
    type: Sequelize.INTEGER
    primaryKey: true
  title:
    type: Sequelize.STRING
    allowNull: false
  description:
    type: Sequelize.TEXT
)

Indicator.sync()

module.exports = Indicator
