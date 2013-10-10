mongoose = require('mongoose')
async = require('async')
_ = require('underscore')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')
SectionSchema = require('./section.coffee').schema
Q = require('q')

pageSchema = mongoose.Schema(
  title: String
  parent_id: mongoose.Schema.Types.ObjectId
  parent_type: String
  sections: [SectionSchema]
  is_draft: type: Boolean, default: false
)

_.extend(pageSchema.statics, sectionNestingModel)

pageSchema.methods.getParent = ->
  Ownable = require("./#{@parent_type.toLowerCase()}.coffee").model
  return Q.nsend(Ownable, 'findOne', @parent_id)

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

Page = mongoose.model('Page', pageSchema)

module.exports = {
  schema: pageSchema
  model: Page
}
