Sequelize = require("sequelize-mysql").sequelize

Narrative = sequelize.define('Narrative',
  title: 
    type: Sequelize.STRING 
    allowNull: false
  content:
    type: Sequelize.TEXT 
    allowNull: false
  id: 
    type: Sequelize.STRING
    primaryKey: true
)

Narrative.sync()

module.exports = Narrative
