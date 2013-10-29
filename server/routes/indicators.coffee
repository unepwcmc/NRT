Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
_ = require('underscore')
async = require('async')
csv = require('express-csv')
Q = require('q')

exports.show = (req, res) ->
  theIndicator = theHeadlines = null

  draftMode = req.path.match(/.*\/draft\/?$/)?
  return res.redirect('back') unless req.isAuthenticated() || !draftMode

  Q.nsend(
    Indicator
      .findOne(_id: req.params.id)
      .populate('owner theme'),
    'exec'
  ).then( (indicator) ->
    theIndicator = indicator

    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    indicator.getRecentHeadlines()
  ).then( (headlines) ->
    theHeadlines = headlines

    theIndicator.toObjectWithNestedPage(draft: draftMode)
  ).then( (indicatorObject) ->
    indicatorObject.headlines = {}
    xAxis = theIndicator.indicatorDefinition?.xAxis

    if xAxis?
      indicatorObject.headlines =
        oldest: theHeadlines[0][xAxis]
        newest: theHeadlines[theHeadlines.length - 1][xAxis]

    res.render("indicators/show",
      indicator: indicatorObject,
      indicatorJSON: JSON.stringify(indicatorObject)
    )
  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )

exports.publishDraft = (req, res) ->
  return res.redirect('back') unless req.isAuthenticated()

  theIndicator = null

  Q.nsend(
    Indicator.findOne(_id: req.params.id),
    'exec'
  ).then( (indicator) ->
    theIndicator = indicator

    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theIndicator.publishDraftPage()
  ).then( (publishedPage) ->

    res.redirect("/indicators/#{theIndicator.id}")

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )

exports.discardDraft = (req, res) ->
  return res.redirect('back') unless req.isAuthenticated()

  theIndicator = null

  Q.nsend(
    Indicator.findOne(_id: req.params.id),
    'exec'
  ).then( (indicator) ->
    theIndicator = indicator

    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theIndicator.discardDraft()
  ).then( (publishedPage) ->

    res.redirect("/indicators/#{theIndicator.id}")

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )
