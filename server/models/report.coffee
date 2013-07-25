Sequelize = require("sequelize-mysql").sequelize

Report = sequelize.define('Report',
  title: 
    type: Sequelize.STRING 
    allowNull: false
  brief: 
    type: Sequelize.TEXT 
    allowNull: false
  introduction: 
    type: Sequelize.TEXT 
    allowNull: false
  conclusion: 
    type: Sequelize.TEXT 
    allowNull: false
  id: 
    type: Sequelize.STRING
    primaryKey: true
)

Report.sync()

module.exports = Report
