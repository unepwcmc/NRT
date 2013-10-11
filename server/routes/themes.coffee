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
        Theme.getIndicatorsByTheme( themeObject.externalId, (err, indicators) ->
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

    theme = theme.toObjectWithNestedPage(draft: true)
    .then((themeObject) ->
      res.render("themes/show",
        theme: theme,
        themeJSON: JSON.stringify(themeObject)
      )
    ).fail((err) ->
      console.error err
      return res.render(500, "Error fetching the theme page")
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.publishDraft = (req, res) ->
  Q.nsend(
    Theme.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (theme) ->
    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    page = null
    theme.publishDraftPage()
    .then( (publishedPage) ->
      theme.toObjectWithNestedPage()
    ).then( (themeObject) ->
      res.render("themes/show",
        theme: theme,
        themeJSON: JSON.stringify(themeObject)
      )
    ).fail((err) ->
      console.error err
      return res.render(500, "Error fetching the theme page")
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.discardDraft = (req, res) ->
  Q.nsend(
    Theme.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (theme) ->
    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    page = null
    theme.discardDraft()
    .then( (publishedPage) ->
      theme.toObjectWithNestedPage()
    ).then( (themeObject) ->
      res.render("themes/show",
        theme: theme,
        themeJSON: JSON.stringify(themeObject)
      )
    ).fail((err) ->
      console.error err
      return res.render(500, "Error fetching the theme page")
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

