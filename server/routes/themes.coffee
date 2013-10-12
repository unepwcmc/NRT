Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
_ = require('underscore')
async = require('async')
Q = require('q')

exports.index = (req, res) ->
  Theme.getFatThemes( (err, themes) ->
    if err?
      console.error err
      return res.render(500, "Error fetching the themes")
    res.render "themes/index", themes: themes
  )

exports.show = (req, res) ->
  Theme
    .findOne(_id: req.params.id)
    .populate('owner')
    .exec( (err, theme) ->
      if err?
        console.error err
        return res.render(500, "Error fetching the theme")

      unless theme?
        error = "Could not find theme with ID #{req.params.id}"
        console.error error
        return res.send(404, error)

      theme.toObjectWithNestedPage().then( (themeObject) ->
        Theme.getIndicatorsByTheme( themeObject._id, (err, indicators) ->
          res.render "themes/show",
            theme: themeObject,
            themeJSON: JSON.stringify(themeObject),
            indicators: indicators
        )
      ).fail( (err) ->
        console.error err
        return res.render(500, "Error fetching theme page")
      )
    )

exports.showDraft = (req, res) ->
  Q.nsend(
    Theme.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (theme) ->
    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theme.toObjectWithNestedPage(draft: true)
  ).then( (themeObject) ->

    Theme.getIndicatorsByTheme( themeObject._id, (err, indicators) ->
      res.render "themes/show",
        theme: themeObject,
        themeJSON: JSON.stringify(themeObject),
        indicators: indicators
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.publishDraft = (req, res) ->
  theTheme = null

  Q.nsend(
    Theme.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (theme) ->
    theTheme = theme

    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theTheme.publishDraftPage()
  ).then( (publishedPage) ->
    theTheme.toObjectWithNestedPage()
  ).then( (themeObject) ->

    Theme.getIndicatorsByTheme( themeObject._id, (err, indicators) ->
      res.render "themes/show",
        theme: themeObject,
        themeJSON: JSON.stringify(themeObject),
        indicators: indicators
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.discardDraft = (req, res) ->
  theTheme = null

  Q.nsend(
    Theme.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (theme) ->
    theTheme = theme

    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theTheme.discardDraft()
  ).then( (publishedPage) ->
    theTheme.toObjectWithNestedPage()
  ).then( (themeObject) ->

    Theme.getIndicatorsByTheme( themeObject._id, (err, indicators) ->
      res.render "themes/show",
        theme: themeObject,
        themeJSON: JSON.stringify(themeObject),
        indicators: indicators
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

