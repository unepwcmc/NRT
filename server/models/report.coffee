Sequelize = require("sequelize-mysql").sequelize

Report = sequelize.define('Report',
  title: 
    type: Sequelize.STRING 
    allowNull: false
  brief: 
    type: Sequelize.TEXT 
    allowNull: true
  introduction: 
    type: Sequelize.TEXT 
    allowNull: true
  conclusion: 
    type: Sequelize.TEXT 
    allowNull: true
  id: 
    type: Sequelize.STRING
    primaryKey: true
)

Report.sync()

module.exports = Report
