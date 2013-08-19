mongoose = require('mongoose')

narrativeSchema = mongoose.Schema(
  content: String
)

Narrative = mongoose.model('Narrative', narrativeSchema)

module.exports = {
  schema: narrativeSchema
  model: Narrative
}
