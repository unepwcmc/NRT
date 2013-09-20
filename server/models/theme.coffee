mongoose = require('mongoose')
request = require('request')
fs = require('fs')
_ = require('underscore')
async = require('async')
Indicator = require('./indicator').model
sectionNestingModel = require('../mixins/section_nesting_model.coffee')

themeSchema = mongoose.Schema(
  title: String
  sections: [mongoose.Schema(
    title: String
    type: String
    indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  )]
  externalId: Number
)

_.extend(themeSchema.statics, sectionNestingModel)

themeSchema.statics.seedData = (callback) ->
  # Seed some themes
  dummyThemes = JSON.parse(
    fs.readFileSync("#{process.cwd()}/lib/sample_themes.json", 'UTF8')
  )

  Theme.count(null, (error, count) ->
    if error?
      console.error error
      return callback(error)

    if count == 0
      Theme.create(dummyThemes, (error, results) ->
        if error?
          console.error error
          return callback(error)
        else
          return callback(null, results)
      )
    else
      callback()
  )

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
          populateFunctions.push(
            (cb) -> 
              Indicator.find(theme: theTheme.externalId).exec( (err, indicators) ->
                themes[theIndex].indicators = indicators
                cb()
              )
          )
        )()
      async.parallel(populateFunctions, (err, results) ->
        callback err, themes
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
  Theme.getIndicatorsByTheme(@externalId, callback)

Theme = mongoose.model('Theme', themeSchema)

module.exports = {
  schema: themeSchema
  model: Theme
}
