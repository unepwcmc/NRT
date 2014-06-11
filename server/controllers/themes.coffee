_ = require('underscore')
async = require('async')
Promise = require('bluebird')

Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
ThemePresenter = require('../lib/presenters/theme')
IndicatorPresenter = require('../lib/presenters/theme')
HeadlineService = require('../lib/services/headline')


paramsToBoolean = (params) ->
  newParams = {}

  for filter, value of params
    if new RegExp("^true$", "i").test(value)
      newParams[filter] = true

  newParams

dpsirParamsToQuery = (params) ->
  queries = []

  for param, value of params
    object = {}
    object["dpsir.#{param}"] = value
    queries.push(object)

  if queries.length > 0
    return {$or: queries}
  else
    return {}

defaultDpsir =
  driver: true
  pressure: true
  state: true
  impact: true
  response: true

exports.index = (req, res) ->
  dpsirFilter = paramsToBoolean(req.query?.dpsir)
  dpsirFilter = defaultDpsir if _.isEmpty(dpsirFilter)

  theThemes = null
  Promise.promisify(
    Theme.find, Theme
  )().then((themes) ->
    theThemes = themes

    if req.query?.dpsir
      filters = dpsirParamsToQuery(dpsirFilter)
    else
      filters = {}

    filters = _.extend(filters, Indicator.CONDITIONS.IS_PRIMARY)
    ThemePresenter.populateIndicators(theThemes, filters)
  ).then(->

    Promise.all(
      for theme in theThemes

        new ThemePresenter(theme).filterIndicatorsWithData().then(->
          # For each indicator of said theme
          Promise.all(
            for indicator in theme.indicators
              indicator.populatePage().then(->
                indicator.populateDescriptionFromPage()
              )
          )
        ).then(->
          HeadlineService.populateNarrativeRecencyOfIndicators(theme.indicators)
        )
    )
  ).then( ->

    Theme.populateDescriptionsFromPages(theThemes)
  ).then(->

    ThemePresenter.populateIndicatorRecencyStats(theThemes)
    res.render "themes/index", themes: theThemes, dpsir: dpsirFilter

  ).catch((err)->
    console.error err
    console.error err.stack
    return res.send(500, "Error loading indicators")
  )

exports.show = (req, res) ->
  mongooseChain = Theme.findOne(_id: req.params.id).populate('owner')
  Promise.promisify(
    mongooseChain.exec,
    mongooseChain
  )().then((theme) ->
    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    indicators = []
    theme.populateIndicators().then(->
      indicators = theme.indicators

      theme.toObjectWithNestedPage()
    ).then((themeObject) ->

      res.render "themes/show",
        theme: themeObject,
        themeJSON: JSON.stringify(themeObject),
        indicators: indicators

    ).catch((err) ->
      console.error err
      return res.render(500, "Error fetching theme page")
    )
  ).catch((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.showDraft = (req, res) ->
  indicators = theTheme = null
  mongooseChain = Theme.findOne(_id: req.params.id).populate('owner')

  Promise.promisify(
    mongooseChain.exec,
    mongooseChain
  )().then((theme) ->
    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theTheme = theme
    theTheme.populateIndicators()
  ).then( ->
    indicators = theTheme.indicators
    theTheme.toObjectWithNestedPage(draft: true)
  ).then((themeObject) ->
    res.render("themes/show",
      theme: themeObject,
      themeJSON: JSON.stringify(themeObject),
      indicators: indicators
    )
  ).catch((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.publishDraft = (req, res) ->
  theTheme = null

  themeFinder = Theme.findOne(_id: req.params.id).populate('owner')
  Promise.promisify(
    themeFinder.exec,
    themeFinder
  )().then( (theme) ->
    theTheme = theme

    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theTheme.publishDraftPage()
  ).then( (publishedPage) ->

    res.redirect("/themes/#{theTheme.id}")

  ).catch((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

exports.discardDraft = (req, res) ->
  theTheme = null

  themeFinder = Theme.findOne(_id: req.params.id).populate('owner')
  Promise.promisify(
    themeFinder.exec,
    themeFinder
  )().then( (theme) ->
    theTheme = theme

    unless theme?
      error = "Could not find theme with ID #{req.params.id}"
      console.error error
      return res.send(404, error)

    theTheme.discardDraft()
  ).then( (publishedPage) ->

    res.redirect("/themes/#{theTheme.id}")

  ).catch((err) ->
    console.error err
    return res.render(500, "Error fetching the theme")
  )

