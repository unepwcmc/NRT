Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
HeadlineService = require('../lib/services/headline')
IndicatorPresenter = require('../lib/presenters/indicator')

_ = require('underscore')
async = require('async')
Q = require('q')

exports.show = (req, res) ->
  theIndicator = theHeadlines = theNarrativeRecency = null

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

    new HeadlineService(indicator).getRecentHeadlines()
  ).then( (headlines) ->
    theHeadlines = headlines

    new IndicatorPresenter(theIndicator).populateNarrativeRecency()
  ).then(->
    # Have to store this has it gets removed in the toObject call below
    theNarrativeRecency = theIndicator.narrativeRecency

    theIndicator.toObjectWithNestedPage(draft: draftMode)
  ).then( (indicatorObject) ->

    # Have to restore this because mongoose squishes it on toObject
    indicatorObject.narrativeRecency = theNarrativeRecency

    presenter = new IndicatorPresenter(indicatorObject)
    presenter.populateIsUpToDate()
    presenter.populateHeadlineRangesFromHeadlines(theHeadlines)
    presenter.populateSourceFromType()

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
