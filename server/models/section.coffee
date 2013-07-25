Sequelize = require("sequelize-mysql").sequelize

Section = sequelize.define('Section',
  title:
    type: Sequelize.STRING
    allowNull: false
  report_id:
    type: Sequelize.INTEGER
  id:
    type: Sequelize.INTEGER
    primaryKey: true
)

Section.sync()

module.exports = Section
