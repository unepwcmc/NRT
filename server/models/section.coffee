Sequelize = require("sequelize-mysql").sequelize
Narrative = require("./narrative.coffee")

Section = sequelize.define('Section',
  title:
    type: Sequelize.STRING
    allowNull: false
  report_id:
    type: Sequelize.INTEGER
    references: "Report"
    referencesKey: "id"
  id:
    type: Sequelize.INTEGER
    primaryKey: true
)

Section.hasMany(Narrative, foreignKey: 'section_id')
Section.sync()

module.exports = Section
