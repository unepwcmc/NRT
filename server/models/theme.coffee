mongoose = require('mongoose')
request = require('request')
fs = require('fs')
_ = require('underscore')
async = require('async')
Indicator = require('./indicator').model

themeSchema = mongoose.Schema(
  title: String
  externalId: Number
)

themeSchema.statics.seedData = (callback) ->
  # Seed some indicators
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

Theme = mongoose.model('Theme', themeSchema)

module.exports = {
  schema: themeSchema
  model: Theme
}
