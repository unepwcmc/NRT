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

      Theme.create(dummyThemes, (error, results) ->
        if error?
          return deferred.reject(error)

        deferred.resolve(results)
      )
    else
      getAllThemes()
  )

  return deferred.promise

themeSchema.statics.getFatThemes = (callback) ->
  Theme.find({})
    .sort(_id: 1)
    .exec( (err, themes) ->
      populateFunctions = []

      for theme, index in themes
        themes[index] = theme.toObject()
        ( ->
          theTheme = theme
          theIndex = index
          theIndicators = null
          populateFunctions.push(
            (cb) ->
              Indicator.findWhereIndicatorHasData(
                theme: theTheme._id
              ).then( (indicators) ->

                theIndicators = Indicator.truncateDescriptions(indicators)

                Indicator.populatePages(theIndicators)
              ).then(->
                Indicator.calculateNarrativeRecency(theIndicators)
              ).then(->
                theTheme.indicators = theIndicators
                cb(null, theTheme)
              ).fail((err) ->
                cb(err)
              )
          )
        )()

      Q.nfcall(
        async.parallel, populateFunctions
      ).then( (populatedThemes) ->
        callback null, populatedThemes
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

themeSchema.methods.getIndicators = (callback) ->
  Theme = require('./theme.coffee').model
  Theme.getIndicatorsByTheme(@_id, callback)

Theme = mongoose.model('Theme', themeSchema)

module.exports = {
  schema: themeSchema
  model: Theme
}
