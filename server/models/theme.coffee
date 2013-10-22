mongoose = require('mongoose')
fs = require('fs')
_ = require('underscore')
async = require('async')
Indicator = require('./indicator').model
Q = require('q')

pageModel = require('../mixins/page_model.coffee')

themeSchema = mongoose.Schema(
  title: String
  externalId: Number
  page: Object
  owner: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
)

_.extend(themeSchema.methods, pageModel)

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

themeSchema.statics.seedData = (callback) ->
  deferred = Q.defer()

  getAllThemes = ->
    Theme.find((err, themes) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve(themes)
    )

  Theme.count(null, (error, count) ->
    if error?
      return deferred.reject(error)

    if count == 0
      dummyThemes = JSON.parse(
        fs.readFileSync("#{process.cwd()}/lib/sample_themes.json", 'UTF8')
      )

      async.map(dummyThemes, createThemeWithSections, (error, results) ->
        if error?
          return deferred.reject(error)

        deferred.resolve(results)
      )
    else
      getAllThemes()
  )

  return deferred.promise


populateThemeIndicators = (theTheme, cb) ->
  theTheme.populateIndicators().then( ->
    cb()
  ).fail((err) ->
    cb(err)
  )

themeSchema.statics.getFatThemes = (callback) ->
  Theme.find({})
    .sort(_id: 1)
    .exec( (err, themes) ->
      Q.nfcall(
        async.each, themes, populateThemeIndicators
      ).then( ->
        callback null, themes
      ).fail( (err) ->
        callback err
      )
    )

themeSchema.statics.getIndicatorsByTheme = (themeId, callback) ->
  Indicator.find(theme: themeId)
    .sort(_id: 1)
    .exec( (err, indicators) ->
      if err?
        console.error(err)
        return callback(err)

      callback(err, indicators)
    )

themeSchema.statics.populateThemeDescriptions = (themes, callback) ->
  deferred = Q.defer()

  populateDescriptions = (theme, callback) ->
    theme.populateDescriptionFromPage().then(->
      callback()
    ).fail(callback)

  async.each themes, populateDescriptions, (err) ->
    if err?
      deferred.reject(err)
    else
      deferred.resolve()

  return deferred.promise

themeSchema.methods.getIndicators = (callback) ->
  Theme = require('./theme.coffee').model
  Theme.getIndicatorsByTheme(@_id, callback)
  
themeSchema.methods.populateIndicators = ->
  theIndicators = null
  Indicator.findWhereIndicatorHasData(
    theme: @_id
    type: "esri"
  ).then( (indicators) ->

    theIndicators = Indicator.truncateDescriptions(indicators)

    Indicator.populatePages(theIndicators)
  ).then(->
    Indicator.calculateNarrativeRecency(theIndicators)
  ).then(=>
    @indicators = theIndicators
    Q.fcall(=> @)
  )

Theme = mongoose.model('Theme', themeSchema)

module.exports = {
  schema: themeSchema
  model: Theme
}
