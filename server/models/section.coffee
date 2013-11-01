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

sectionSchema.statics.createSectionWithNarrative = (attributes, callback) ->
  Section = require('./section.coffee').model
  Narrative = require('./narrative.coffee').model

  savedSection = null

  section = new Section(title: attributes.title)
  Q.nsend(
    section, 'save'
  ).spread( (section, rowsChanged) ->
    savedSection = section

    narrative = new Narrative(section: savedSection.id, content: attributes.content)

    Q.nsend(
      narrative, 'save'
    )
  ).then( (savedNarrative) ->
    callback(null, savedSection)
  ).fail( (err) ->
    callback(err)
  )


# METHODS
sectionSchema.methods.getNarrative = () ->
  deferred = Q.defer()

  Narrative.find(section: @_id, (err, narratives) ->
    if err?
      deferred.reject err
    else
      deferred.resolve narratives[0]
  )

  return deferred.promise

sectionSchema.methods.getFatChildren = ->
  deferred = Q.defer()

  children = {}

  Q.nsend(
    Narrative.findOne({section: @_id}), 'exec'
  ).then( (narrative) =>
    if narrative?
      children.narrative = narrative.toObject()

    Q.nsend(
      Visualisation, 'findFatVisualisation', section: @_id
    )
  ).then( (visualisation) ->
    if visualisation?
      children.visualisation = visualisation.toObject()

    deferred.resolve(children)
  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

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
