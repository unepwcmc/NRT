mongoose = require('mongoose')
request = require('request')
fs = require('fs')
_ = require('underscore')
async = require('async')
Q = require('q')
moment = require('moment')

IndicatorData = require('./indicator_data').model
Page = require('./page').model

# Mixins
pageModel = require('../mixins/page_model.coffee')
updateIndicatorMixin = require('../mixins/update_indicator_data.coffee')

indicatorSchema = mongoose.Schema(
  title: String
  short_name: String
  indicatorDefinition: mongoose.Schema.Types.Mixed
  theme: {type: mongoose.Schema.Types.ObjectId, ref: 'Theme'}
  type: String
  owner: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
  description: String
)

_.extend(indicatorSchema.methods, pageModel)
_.extend(indicatorSchema.methods, updateIndicatorMixin.methods)
_.extend(indicatorSchema.statics, updateIndicatorMixin.statics)

replaceThemeNameWithId = (indicators) ->
  Theme = require('./theme').model

  deferred = Q.defer()

  getThemeFromTitle = (indicator, callback) ->
    Theme.findOne(title: indicator.theme, (err, theme) ->
      if err? or !theme?
        return callback(err)

      indicator.theme = theme._id
      callback(null, indicator)
    )

  async.map(indicators, getThemeFromTitle, (err, indicatorsWithThemes) ->
    if err?
      deferred.reject(err)

    deferred.resolve(indicatorsWithThemes)
  )

  return deferred.promise

createSectionWithNarrative = (attributes, callback) ->
  Section = require('./section.coffee').model
  Narrative = require('./narrative.coffee').model

  savedSection = null

  section = new Section(title: attributes.title)
  Q.nsend(
    section, 'save'
  ).spread( (section, rowsChanged) ->
    savedSection = section

    narrative = new Narrative(section: savedSection.id, content: attributes.content)

    Q.nsend(
      narrative, 'save'
    )
  ).then( (savedNarrative) ->
    callback(null, savedSection)
  ).fail( (err) ->
    callback(err)
  )

createIndicatorWithSections = (indicatorAttributes, callback) ->
  theIndicator = thePage = null

  Q.nsend(
    Indicator, 'create', indicatorAttributes
  ).then( (indicator) ->
    theIndicator = indicator
    theIndicator.getPage()
  ).then( (page) ->
    thePage = page

    sections = indicatorAttributes.sections

    Q.nsend(
      async, 'map', sections, createSectionWithNarrative
    )
  ).then( (sections) ->

    thePage.sections = thePage.sections.concat(sections || [])

    Q.nsend(
      thePage, 'save'
    )
  ).then( (page) ->
    callback(null, theIndicator)
  ).fail( (err) ->
    callback(err)
  )

indicatorSchema.statics.seedData = ->
  deferred = Q.defer()

  getAllIndicators = ->
    Indicator.find((err, indicators) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve(indicators)
    )

  Indicator.count(null, (error, count) ->
    if error?
      return deferred.reject(error)

    if count is 0
      dummyIndicators = JSON.parse(
        fs.readFileSync("#{process.cwd()}/lib/seed_indicators.json", 'UTF8')
      )

      replaceThemeNameWithId(
        dummyIndicators
      ).then( (indicators) ->
        async.map(dummyIndicators, createIndicatorWithSections, (err, indicators) ->
          deferred.resolve(indicators)
        )
      ).fail( (err) ->
        deferred.reject(error)
      )
    else
      getAllIndicators()
  )

  return deferred.promise

indicatorSchema.statics.truncateDescription = (indicator) ->
  description = indicator.description
  if description? and description.length > 80
    indicator.description = "#{description.substring(0,80)}..."

  return indicator

indicatorSchema.statics.truncateDescriptions = (indicators) ->
  for indicator in indicators
    Indicator.truncateDescription(indicator)

  return indicators

indicatorSchema.methods.getIndicatorDataForCSV = (filters, callback) ->
  if arguments.length == 1
    callback = filters
    filters = {}

  @getIndicatorData(filters, (err, indicatorData) =>
    xAxis = @indicatorDefinition.xAxis
    yAxis = @indicatorDefinition.yAxis

    rows = [[xAxis, yAxis]]

    for row in indicatorData
      rows.push [row[xAxis], row[yAxis]]

    callback(err, rows)
  )

indicatorSchema.methods.getIndicatorData = (filters, callback) ->
  if arguments.length == 1
    callback = filters
    filters = {}

  IndicatorData.findOne indicator: @_id, (err, res) ->
    if err?
      console.error err
      callback err
    else if !res?
      callback null, []
    else
      data = filterIndicatorData(res.data, filters)

      callback null, data

# Filter the given data according to the given filters
filterIndicatorData = (data, filters) ->
  for field, operations of filters
    for operation, value of operations
      if filterOperations[operation]?
        data = filterOperations[operation](data, field, value)
      else
        console.error "No function to perform filter operation '#{operation}'"

  return data

# Functions which filter indicator data using different operations
filterOperations =
  min: (data, field, value) ->
    _.filter(data, (row) ->
      row[field] >= value
    )
  max: (data, field, value) ->
    _.filter(data, (row) ->
      row[field] <= value
    )

indicatorSchema.methods.calculateIndicatorDataBounds = (callback) ->
  @getIndicatorData((error, data) =>
    bounds = {}

    unless @indicatorDefinition.fields?
      errorMsg = "Indicator definition does not list fields, cannot get bounds"
      console.error(errorMsg)
      callback(errorMsg)

    for field in @indicatorDefinition.fields
      bounds[field.name] = boundAggregators[field.type](data, field.name, field.name)

    callback(null, bounds)
  )

# Functions to aggregate the data bounds of different types of fields
boundAggregators =
  integer: (data, fieldName) ->
    bounds = {}
    bounds.min = _.min(data, (row) ->
      row[fieldName]
    )[fieldName]
    bounds.max = _.max(data, (row) ->
      row[fieldName]
    )[fieldName]
    return bounds
  text: () -> "It's text, dummy"

indicatorSchema.methods.getRecentHeadlines = (amount) ->
  deferred = Q.defer()

  Q.nsend(
    @, 'getIndicatorData'
  ).then( (data) =>

    headlineData = _.last(data, amount)
    headlines = IndicatorData.convertDataToHeadline(headlineData)

    deferred.resolve(headlines.reverse())

  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

indicatorSchema.methods.getNewestHeadline = ->
  deferred = Q.defer()

  @getRecentHeadlines(1).then((headlines) ->
    deferred.resolve headlines[0]
  ).fail( (err) ->
    deferred.reject err
  )

  return deferred.promise

# Probably going to need a refactor at some point
indicatorSchema.methods.getCurrentYAxis = (callback) ->
  @getIndicatorData((error, data) =>
    if error?
      callback(error)

    mostCurrentData = _.max(data, (row)=>
      row[@indicatorDefinition.xAxis]
    )
    callback(null, mostCurrentData[@indicatorDefinition.yAxis])
  )

# Add currentYValue to a collection of indicators
indicatorSchema.statics.calculateCurrentValues = (indicators, callback) ->
  currentValueGatherers = []
  for indicator in indicators
    currentValueGatherers.push((->
      theIndicator = indicator #Closure indicator variable

      return (callback) ->
        theIndicator.getCurrentYAxis((error, value)->
          if error?
            console.error error
            callback(error)

          theIndicator.currentValue = value
          callback()
        )
    )())

  async.parallel(
    currentValueGatherers
    , (err, items) ->
      callback(null, indicators)
  )

indicatorSchema.statics.findWhereIndicatorHasData = (conditions) ->
  deferred = Q.defer()

  Q.nsend(
    Indicator.find(conditions), 'exec'
  ).then((indicators) ->
    indicatorsWithData = []

    addIndicatorIfHasData = (indicator, callback) ->
      indicator.getIndicatorData((err, data) ->
        if err?
          return callback(err)
        else if data.length > 0
          indicatorsWithData.push indicator
        callback()
      )

    async.each indicators, addIndicatorIfHasData, (err) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve(indicatorsWithData)

  ).fail((err)->
    deferred.reject(err)
  )

  return deferred.promise

indicatorSchema.methods.calculateRecencyOfHeadline = ->
  deferred = Q.defer()

  @populatePage().then( =>
    @getNewestHeadline()
  ).then( (dataHeadline) =>

    unless dataHeadline?
      return deferred.resolve("No Data")

    pageHeadline = @page.headline

    unless pageHeadline? && pageHeadline.periodEnd?
      return deferred.resolve("Out of date")

    if moment(pageHeadline.periodEnd).isBefore(dataHeadline.periodEnd)
      deferred.resolve("Out of date")
    else
      deferred.resolve("Up to date")

  ).fail( (err) ->
    deferred.reject(err)
  )

  return deferred.promise

populatePage = (indicator, callback) ->
  indicator.populatePage().then(->
    callback()
  ).fail((err) ->
    callback(err)
  )

indicatorSchema.statics.populatePages = (indicators) ->
  deferred = Q.defer()

  async.each indicators, populatePage, (err) ->
    if err?
      deferred.reject(err)
    else
      deferred.resolve()
  
  return deferred.promise

calculateRecency = (indicator, callback) ->
  indicator.calculateRecencyOfHeadline().then((recency)->
    indicator.narrativeRecency = recency
    callback()
  ).fail((err) ->
    callback(err)
  )

indicatorSchema.statics.calculateNarrativeRecency = (indicators) ->
  deferred = Q.defer()

  async.each indicators, calculateRecency, (err) ->
    if err?
      deferred.reject(err)
    else
      deferred.resolve()

  return deferred.promise

Indicator = mongoose.model('Indicator', indicatorSchema)

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}
