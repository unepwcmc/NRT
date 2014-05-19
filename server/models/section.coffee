Narrative = require("./narrative.coffee").model
Visualisation = require("./visualisation.coffee").model
mongoose = require('mongoose')
Q = require 'q'
async = require('async')
Promise = require('bluebird')

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
sectionSchema.statics.cloneChildren = (clonedSectionAndOriginalSectionId) ->
  section = clonedSectionAndOriginalSectionId.section
  originalSectionId = clonedSectionAndOriginalSectionId.originalId

  section.cloneChildrenBySectionId(originalSectionId)

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

sectionSchema.methods.cloneChildrenBySectionId = (originalSectionId) ->
  @cloneNarrativesFrom(
    originalSectionId
  ).then( =>
    @cloneVisualisationsFrom(originalSectionId)
  )

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
  new Promise( (resolve, reject) =>
    Promise.promisify(Visualisation.find, Visualisation)(
      section: sectionId
    ).then( (visualisations) =>
      async.map(visualisations, cloneVisualisation.bind(@), (err, clonedvisualisations) ->
        if err?
          reject(err)

        resolve(clonedvisualisations)
      )
    ).catch(reject)
  )

sectionSchema.methods.cloneNarrativesFrom = (sectionId) ->

  new Promise( (resolve, reject) =>
    Promise.promisify(Narrative.find, Narrative)(
      section: sectionId
    ).then( (narratives) =>

      async.map(narratives, cloneNarrative.bind(@), (err, clonedNarratives) ->
        if err?
          reject(err)

        resolve(clonedNarratives)
      )
    ).catch(reject)
  )


Section = mongoose.model('Section', sectionSchema)

module.exports = {
  schema: sectionSchema
  model: Section
}
