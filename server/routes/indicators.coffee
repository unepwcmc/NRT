Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
_ = require('underscore')
async = require('async')
csv = require('express-csv')
Q = require('q')

exports.index = (req, res) ->
  Theme.getFatThemes( (err, themes) ->
    if err?
      console.error err
      return res.render(500, "Error fetching the themes")
    res.render "indicators/index", themes: themes
  )

exports.show = (req, res) ->
  Q.nsend(
    Indicator.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (indicator) ->
    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    indicator.toObjectWithNestedPage()
    .then((indicatorObject) ->
      res.render("indicators/show",
        indicator: indicatorObject, indicatorJSON: JSON.stringify(indicatorObject)
      )
    ).fail((err) ->
      console.error err
      return res.render(500, "Error fetching the indicator page")
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )

exports.showDraft = (req, res) ->
  Q.nsend(
    Indicator.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (indicator) ->
    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    indicator.toObjectWithNestedPage(draft: true)
  ).then( (indicatorObject) ->
    res.render("indicators/show",
      indicator: indicatorObject,
      indicatorJSON: JSON.stringify(indicatorObject)
    )
  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )

exports.publishDraft = (req, res) ->
  theIndicator = null

  Q.nsend(
    Indicator.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (indicator) ->
    theIndicator = indicator

    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theIndicator.publishDraftPage()
  ).then( (publishedPage) ->
    theIndicator.toObjectWithNestedPage()
  ).then( (indicatorObject) ->

    res.render("indicators/show",
      indicator: indicatorObject,
      indicatorJSON: JSON.stringify(indicatorObject)
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )

exports.discardDraft = (req, res) ->
  theIndicator = null

  Q.nsend(
    Indicator.findOne(_id: req.params.id).populate('owner'),
    'exec'
  ).then( (indicator) ->
    theIndicator = indicator

    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theIndicator.discardDraft()
  ).then( (publishedPage) ->
    theIndicator.toObjectWithNestedPage()
  ).then( (indicatorObject) ->

    res.render("indicators/show",
      indicator: indicatorObject,
      indicatorJSON: JSON.stringify(indicatorObject)
    )

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )

