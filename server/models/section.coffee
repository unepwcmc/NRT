Narrative = require("./narrative.coffee").schema
mongoose = require('mongoose')

sectionSchema = mongoose.Schema(
  title: String
  narratives: [Narrative]
)

Section = mongoose.model('Section', sectionSchema)

module.exports = {
  schema: sectionSchema
  model: Section
}
