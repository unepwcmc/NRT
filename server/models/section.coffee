Narrative = require("./narrative.coffee").schema
Visualisation = require("./visualisation.coffee").schema
Indicator = require("./indicator.coffee").schema
mongoose = require('mongoose')

sectionSchema = mongoose.Schema(
  title: String
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
)

sectionSchema.statics.getValidationErrors = (attributes) ->
  errors = []
  unless attributes['title']? or attributes['indicator']
    errors.push "title or indicator must be present"
  return errors

Section = mongoose.model('Section', sectionSchema)

module.exports = {
  schema: sectionSchema
  model: Section
}
