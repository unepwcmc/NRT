Sequelize = require("sequelize-mysql").sequelize

Visualisation = sequelize.define('Visualisation',
  id:
    type: Sequelize.INTEGER
    primaryKey: true
  data:
    type: Sequelize.TEXT
    allowNull: false
  section_id:
    type: Sequelize.INTEGER
    references: "Section"
    referencesKey: "id"
)

Visualisation.sync()

module.exports = Visualisation
