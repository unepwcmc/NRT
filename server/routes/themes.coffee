Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
_ = require('underscore')
async = require('async')

exports.index = (req, res) ->
  Theme.getFatThemes( (err, themes) ->
    if err?
      console.error err
      return res.render(500, "Error fetching the themes")
    res.render "themes/index", themes: themes
  )

exports.show = (req, res) ->
  Theme
    .findOne(_id: req.params.id, (err, theme) ->
      if err?
        console.error err
        return res.render(500, "Error fetching the theme")

      theme.toObjectWithNestedPage().then( (themeObject) ->
        Theme.getIndicatorsByTheme( themeObject.externalId, (err, indicators) ->
          res.render "themes/show",
            theme: themeObject,
            themeJSON: JSON.stringify(themeObject),
            indicators: indicators
        )
      ).fail( (err) ->
        console.error err
        throw new Error(err)
      )
    )
