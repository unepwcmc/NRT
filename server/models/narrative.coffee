Sequelize = require("sequelize-mysql").sequelize

Narrative = sequelize.define('Narrative',
  content:
    type: Sequelize.TEXT
    allowNull: false
  id:
    type: Sequelize.STRING
    primaryKey: true
  section_id:
    type: Sequelize.INTEGER
    references: "Section"
    referencesKey: "id"
)

Narrative.sync()

module.exports = Narrative
