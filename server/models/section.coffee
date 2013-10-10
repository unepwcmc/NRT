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
    ).then( =>
      @cloneIndicatorFrom(originalSectionId)
    ).then( ->
      deferred.resolve()
    ).fail( (err) ->
      deferred.reject(err)
    )

  return deferred.promise

sectionSchema.methods.cloneIndicatorFrom = (sectionId) ->
  Indicator = require("./indicator.coffee").model

  deferred = Q.defer()

  Q.nsend(
    Section
      .findOne(_id: sectionId)
      .populate('indicator')
    , 'exec'
  ).then( (oldSection) ->

    unless oldSection? && oldSection.indicator?
      deferred.resolve()

    indicator = oldSection.indicator.toObject()
    delete indicator._id

    Q.nsend(
      Indicator, 'create', indicator
    )

  ).then( (newIndicator) =>

    @indicator = newIndicator
    Q.nsend(@, 'save')

  ).then( =>

    deferred.resolve(@indicator)

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

sectionSchema.methods.cloneVisualisationsFrom = (sectionId) ->
  deferred = Q.defer()

  Q.nsend(
    Visualisation.find(section: sectionId), 'exec'
  ).then( (visualisations) =>

    async.map(visualisations, cloneVisualisation.bind(@), (err, clonedvisualisations) ->
      if err?
        deferred.reject(err)

      deferred.resolve(clonedvisualisations)
    )

  ).fail( (err) ->
    deferred.reject(err)
  )
  return deferred.promise

sectionSchema.methods.cloneNarrativesFrom = (sectionId) ->
  deferred = Q.defer()

  Q.nsend(
    Narrative.find(section: sectionId), 'exec'
  ).then( (narratives) =>

    async.map(narratives, cloneNarrative.bind(@), (err, clonedNarratives) ->
      if err?
        deferred.reject(err)

      deferred.resolve(clonedNarratives)
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
