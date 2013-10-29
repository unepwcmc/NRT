mongoose = require('mongoose')
async = require('async')
_ = require('underscore')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')
SectionSchema = require('./section.coffee').schema
Q = require('q')
moment = require('moment')

pageSchema = mongoose.Schema(
  title: String
  parent_id: mongoose.Schema.Types.ObjectId
  parent_type: String
  sections: [SectionSchema]
  is_draft: type: Boolean, default: false
  headline: mongoose.Schema.Types.Mixed
)

_.extend(pageSchema.statics, sectionNestingModel)

pageSchema.methods.getParent = ->
  Ownable = require("./#{@parent_type.toLowerCase()}.coffee").model
  return Q.nsend(Ownable, 'findOne', _id: @parent_id)

pageSchema.methods.createDraftClone = ->
  Section = require('./section.coffee').model
  deferred = Q.defer()
  clonedPage = null

  attributes = @toObject()
  delete attributes._id
  attributes.is_draft = true

  Q.nsend(
    Page, 'create', attributes
  ).then( (page) ->
    clonedPage = page

    clonedPage.giveSectionsNewIds()
  ).then( (clonedSectionsAndOriginalSectionIds) ->

    async.each(clonedSectionsAndOriginalSectionIds, Section.cloneChildren, (err) ->
      if err?
        deferred.reject(err)

      deferred.resolve(clonedPage)
    )

  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

giveSectionNewId = (section, callback) ->
  originalSectionId = section.id
  section._id = mongoose.Types.ObjectId()

  section.save( (err) ->
    if err?
      callback(err)

    callback(null,
      originalId: originalSectionId
      section: section
    )
  )

pageSchema.methods.giveSectionsNewIds = ->
  deferred = Q.defer()

  async.map(@sections, giveSectionNewId, (err, sectionsWithOriginalIds) ->
    if err?
      deferred.reject(err)

    deferred.resolve(sectionsWithOriginalIds)
  )

  return deferred.promise

pageSchema.methods.getOwnable = ->
  @getParent()

pageSchema.methods.canBeEditedBy = (user) ->
  deferred = Q.defer()

  if user?
    deferred.resolve()
  else
    deferred.reject(new Error('Must be authenticated as a user to edit pages'))

  return deferred.promise

pageSchema.pre('save', (next) ->
  if @headline?
    next()
  else
    @setHeadlineToMostRecentFromParent().then(->
      next()
    ).fail((err) ->
      console.error err
      next(err)
    )
)

NO_DATA_HEADLINE =
  text: "Not reported on"
  value: "-"
  periodEnd: null

pageSchema.methods.setHeadlineToMostRecentFromParent = ->
  deferred = Q.defer()

  if @parent_type is 'Indicator'
    @getParent().then( (parent) ->
      parent.getNewestHeadline()
    ).then( (headline) =>
      if headline?
        @headline = headline
      else
        @headline = NO_DATA_HEADLINE

      deferred.resolve(@headline)
    ).fail( (err) ->
      deferred.reject(err)
    )
  else
    deferred.resolve()

  return deferred.promise

pageSchema.methods.createSectionNarratives = (attributes) ->
  deferred = Q.defer()

  unless attributes?
    deferred.resolve()

  Section = require('./section').model
  Q.nsend(
    async, 'map', attributes, Section.createSectionWithNarrative
  ).then( (sections) =>

    @sections = @sections.concat(sections || [])

    Q.nsend(
      @, 'save'
    )
  ).then(->
    deferred.resolve()
  ).fail((err) ->
    deferred.reject(err)
  )

  return deferred.promise

Page = mongoose.model('Page', pageSchema)

module.exports = {
  schema: pageSchema
  model: Page
}
