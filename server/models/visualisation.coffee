mongoose = require('mongoose')

visualisationSchema = mongoose.Schema(
  data: mongoose.Schema.Types.Mixed
)

Visualisation = mongoose.model('Visualisation', visualisationSchema)

module.exports = {
  schema: visualisationSchema,
  model: Visualisation
}
