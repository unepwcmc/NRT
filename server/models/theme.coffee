mongoose = require('mongoose')
fs = require('fs')
_ = require('underscore')
async = require('async')
Q = require('q')
Promise = require('bluebird')

Indicator = require('./indicator').model
HeadlineService = require('../lib/services/headline')
pageModelMixin = require('../mixins/page_model.coffee')

themeSchema = mongoose.Schema(
  title: String
  externalId: Number
  image_url: String
  page: Object
  owner: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
)

_.extend(themeSchema.methods, pageModelMixin.methods)
_.extend(themeSchema.statics, pageModelMixin.statics)

createThemeWithSections = (themeAttributes, callback) ->
  theTheme = thePage = null

  Q.nsend(
    Theme, 'create', themeAttributes
  ).then( (theme) ->
    theTheme = theme
    theTheme.getPage()
  ).then( (page) ->
    thePage = page

    sections = themeAttributes.sections

    thePage.createSectionNarratives(sections)
  ).then( (page) ->
    callback(null, theTheme)
  ).fail( (err) ->
    callback(err)
  )

themeSchema.statics.seedData = (seedsPath) ->
  new Promise( (resolve, reject) ->
    unless fs.existsSync(seedsPath)
      throw new Error(
        "Unable to load theme seed file, have you copied seeds from config/instances/ to config/seeds/?"
      )

    Promise.promisify(fs.readFile, fs)(
      seedsPath, 'UTF8'
    ).then(
      JSON.parse
    ).then( (dummyThemes) ->
      async.map(dummyThemes, createThemeWithSections, (error, results) ->
        if error?
          return reject(error)

        resolve(results)
      )
    )
  )

populateThemeIndicators = (theTheme, cb) ->
  theTheme.populateIndicators().then( ->
    cb()
  ).catch((err) ->
    cb(err)
  )

themeSchema.statics.getFatThemes = (callback) ->
  Theme.find({})
    .sort(_id: 1)
    .exec( (err, themes) ->
      if err?
        callback err
      else
        Q.nfcall(
          async.each, themes, populateThemeIndicators
        ).then( ->
          callback null, themes
        ).fail( (err) ->
          callback err
        )
    )

themeSchema.statics.getIndicatorsByTheme = (themeId, filters, callback) ->
  unless callback?
    callback = filters
    filters = {}

  filters = _.extend(theme: themeId, filters)

  Indicator.find(filters)
    .sort(_id: 1)
    .exec( (err, indicators) ->
      if err?
        console.error(err)
        return callback(err)

      callback(err, indicators)
    )

themeSchema.methods.getIndicators = (callback) ->
  Theme = require('./theme.coffee').model
  Theme.getIndicatorsByTheme(@_id, callback)

themeSchema.methods.populateIndicators = (filters) ->
  theIndicators = null

  filters ||= {primary: true}
  filters = _.extend({theme: @_id}, filters)

  Indicator.findWhereIndicatorHasData(
    filters
  ).then( (indicators) ->
    theIndicators = indicators

    Indicator.populatePages(theIndicators)
  ).then(->
    Indicator.populateDescriptionsFromPages(theIndicators)
  ).then(->
    HeadlineService.populateNarrativeRecencyOfIndicators(theIndicators)
  ).then(=>
    @indicators = theIndicators.sort(_id: 1)
    Q.fcall(=> @)
  )

themeSchema.statics.findOrCreateByTitle = (title) ->
  new Promise((resolve, reject) =>
    @findOne({title: title}, (err, theme) ->
      return reject(err) if err?
      if theme?
        resolve(theme)
      else
        Promise.promisify(Theme.create, Theme)(title: title).then(
          resolve, reject
        )

    )
  )

Theme = mongoose.model('Theme', themeSchema)

module.exports = {
  schema: themeSchema
  model: Theme
}
