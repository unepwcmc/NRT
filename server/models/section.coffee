Sequelize = require("sequelize-mysql").sequelize
Narrative = require("./narrative.coffee")

Section = sequelize.define('Section',
  title:
    type: Sequelize.STRING
  report_id:
    type: Sequelize.INTEGER
    references: "Report"
    referencesKey: "id"
  indicator:
    type: Sequelize.INTEGER
    references: "Indicator"
    referencesKey: "id"
  id:
    type: Sequelize.INTEGER
    primaryKey: true
)

Section.hasMany(Narrative, foreignKey: 'section_id')
Section.sync()

Section.getValidationErrors = (attributes) ->
  errors = []
  unless attributes['title']? or attributes['indicator']
    errors.push "title or indicator must be present"
  return errors

module.exports = Section
