Narrative = require("./narrative.coffee").model
Visualisation = require("./visualisation.coffee").model
mongoose = require('mongoose')
Q = require 'q'
async = require('async')

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
  originalSectionId = clonedSectionAndOriginalSectionId.originalId

  section.cloneChildrenBySectionId(originalSectionId)
    .then(-> callback(null))
    .fail(callback)

# METHODS
sectionSchema.methods.cloneChildrenBySectionId = (originalSectionId) ->
  deferred = Q.defer()

  @cloneNarrativesFrom(originalSectionId)
    .then( =>
      @cloneVisualisationsFrom(originalSectionId)
    ).then( ->
      deferred.resolve()
    ).fail( (err) ->
      deferred.reject(err)
    )

  return deferred.promise

cloneNarrative = (narrative, callback) ->
  narrativeAttributes = narrative.toObject()
  delete narrativeAttributes._id
  narrativeAttributes.section = @_id

  Narrative.create(narrativeAttributes, (err, clonedNarrative) ->
    if err?
      return callback(err)

    callback(null, clonedNarrative)
  )

cloneVisualisation = (visualisation, callback) ->
  visualisationAttributes = visualisation.toObject()
  delete visualisationAttributes._id
  visualisationAttributes.section = @_id

  Visualisation.create(visualisationAttributes, (err, clonedVisualisation) ->
    if err?
      return callback(err)

    callback(null, clonedVisualisation)
  )

sectionSchema.methods.cloneNarrativesFrom = (sectionId) ->
  deferred = Q.defer()

  @cloneNestedObjectsFromSection(Narrative, sectionId).then( (narratives) ->
    deferred.resolve(narratives)
  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

sectionSchema.methods.cloneVisualisationsFrom = (sectionId) ->
  deferred = Q.defer()

  @cloneNestedObjectsFromSection(Visualisation, sectionId).then( (visualisations) ->
    deferred.resolve(visualisations)
  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

sectionSchema.methods.cloneNestedObjectsFromSection = (object, sectionId) ->
  deferred = Q.defer()

  Q.nsend(
    object.find(section: sectionId), 'exec'
  ).then( (objects) =>

    method = cloneVisualisation.bind(@)
    method = cloneNarrative.bind(@) if object == Narrative

    async.map(objects, method, (err, clonedObjects) ->
      if err?
        deferred.reject(err)

      deferred.resolve(clonedObjects)
    )

  ).fail( (err) ->
    deferred.reject(err)
  )
  return deferred.promise

Section = mongoose.model('Section', sectionSchema)

module.exports = {
  schema: sectionSchema
  model: Section
}
