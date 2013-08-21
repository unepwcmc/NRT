mongoose = require('mongoose')

narrativeSchema = mongoose.Schema(
  section: String
  content: String
)

Narrative = mongoose.model('Narrative', narrativeSchema)

module.exports = {
  schema: narrativeSchema
  model: Narrative
}
