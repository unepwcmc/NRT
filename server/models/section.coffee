Narrative = require("./narrative.coffee").schema
Visualisation = require("./visualisation.coffee").schema
mongoose = require('mongoose')
Q = require 'q'

sectionSchema = mongoose.Schema(
  title: String
  type: String
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
)

# STATICS
sectionSchema.statics.getValidationErrors = (attributes) ->
  errors = []
  unless attributes['title']? or attributes['indicator']
    errors.push "title or indicator must be present"
  return errors

# Given an object with a cloned section and a target section id,
# clones the children of the target section to the clone section
sectionSchema.statics.cloneChildren = (clonedSectionAndOriginalSectionId, callback) ->
  section = clonedSectionAndOriginalSectionId.section
  originalSectionId = clonedSectionAndOriginalSectionId.originalSectionId

  section.cloneChildrenBySectionId(originalSectionId)
    .then(-> callback(nil))
    .fail(callback)

# METHODS
sectionSchema.methods.cloneChildrenBySectionId = ->
  deferred = Q.defer()

  @cloneNarratives()
    .then( ->
      deferred.resolve()
    ).fail( (err)
      deferred.reject(err)
    )

  return deferred.promise

Section = mongoose.model('Section', sectionSchema)

module.exports = {
  schema: sectionSchema
  model: Section
}
