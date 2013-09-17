mongoose = require('mongoose')
request = require('request')
fs = require('fs')
_ = require('underscore')
async = require('async')
Indicator = require('./indicator').model

themeSchema = mongoose.Schema(
  title: String
)

themeSchema.statics.getFatThemes = (callback) ->
  Theme.find({})
    .exec( (err, themes) -> 
      populateFunctions = []
      for theme, index in themes
        themes[index] = theme.toObject()
        ( ->
          theTheme = theme
          theIndex = index
          populateFunctions.push(
            (cb) -> 
              Indicator.find(theme: theTheme._id).exec( (err, indicators) ->
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
