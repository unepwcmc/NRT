mongoose = require('mongoose')
async = require('async')
_ = require('underscore')
HeadlineService = require('../lib/services/headline.coffee')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')
SectionSchema = require('./section.coffee').schema
Q = require('q')
moment = require('moment')
Promise = require('bluebird')

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
  findOneAsync = Promise.promisify(Ownable.findOne, Ownable)
  return  findOneAsync(_id: @parent_id)

pageSchema.methods.createDraftClone = ->
  Section = require('./section.coffee').model
  clonedPage = null

  attributes = @toObject()
  delete attributes._id
  attributes.is_draft = true

  Promise.promisify(Page.create, Page)(
    attributes
  ).then( (page) ->
    clonedPage = page

    clonedPage.giveSectionsNewIds()
  ).then( (clonedSectionsAndOriginalSectionIds) ->
    clonePromises = clonedSectionsAndOriginalSectionIds.map(
      Section.cloneChildren
    )
    Promise.all(clonePromises)
  ).then( ->
    Promise.promisify(clonedPage.save, clonedPage)()
  ).then( ->
    Promise.resolve(clonedPage)
  )

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
  new Promise( (resolve, reject) =>
    async.map(@sections, giveSectionNewId, (err, sectionsWithOriginalIds) ->
      if err?
        reject(err)

      resolve(sectionsWithOriginalIds)
    )
  )

pageSchema.methods.getOwnable = ->
  @getParent()

pageSchema.methods.canBeEditedBy = (user) ->
  if user?
    Promise.resolve()
  else
    Promise.reject(new Error('Must be authenticated as a user to edit pages'))

pageSchema.pre('save', (next) ->
  if @headline?
    next()
  else
    @setHeadlineToMostRecentFromParent().then(->
      next()
    ).catch((err) ->
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
      headlineService = new HeadlineService(parent)
      headlineService.getNewestHeadline()
    ).then( (headline) =>
      if headline?
        @headline = headline
      else
        @headline = NO_DATA_HEADLINE

      deferred.resolve(@headline)
    ).catch( (err) ->
      deferred.reject(err)
    )
  else
    deferred.resolve()

  return deferred.promise

pageSchema.methods.createSectionNarratives = (attributes) ->
  unless attributes?
    return Promise.resolve()

  Section = require('./section').model

  Promise.promisify(async.map, async)(
    attributes, Section.createSectionWithNarrative
  ).then((sections) =>

    @sections = @sections.concat(sections || [])

    Promise.promisify(@save, @)()
  )


Page = mongoose.model('Page', pageSchema)

module.exports = {
  schema: pageSchema
  model: Page
}
