mongoose = require('mongoose')

narrativeSchema = mongoose.Schema(
  section_id: String
  content: String
)

Narrative = mongoose.model('Narrative', narrativeSchema)

module.exports = {
  schema: narrativeSchema
  model: Narrative
}
