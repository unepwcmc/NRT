Narrative = require("./narrative.coffee").schema
Visualisation = require("./visualisation.coffee").schema
Indicator = require("./indicator.coffee").schema
mongoose = require('mongoose')

sectionSchema = mongoose.Schema(
  title: String
  narrative: {type: mongoose.Schema.Types.ObjectId, ref: 'Narrative'}
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  visualisation: {type: mongoose.Schema.Types.ObjectId, ref: 'Visualisation'}
)

Section = mongoose.model('Section', sectionSchema)

module.exports = {
  schema: sectionSchema
  model: Section
}
