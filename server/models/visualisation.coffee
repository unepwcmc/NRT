mongoose = require('mongoose')

visualisationSchema = mongoose.Schema(
  data: mongoose.Schema.Types.Mixed
  section_id: String
)

Visualisation = mongoose.model('Visualisation', visualisationSchema)

module.exports = {
  schema: visualisationSchema,
  model: Visualisation
}
