mongoose = require('mongoose')
request = require('request')
fs = require('fs')
_ = require('underscore')
async = require('async')
Q = require('q')
moment = require('moment')
Promise = require('bluebird')

AppConfig = require('../initializers/config')

IndicatorData = require('./indicator_data').model
Page = require('./page').model

HeadlineService = require '../lib/services/headline'

indicatorSchema = mongoose.Schema(
  name: String
  shortName: String
  indicatorDefinition: mongoose.Schema.Types.Mixed
  indicatorationConfig:
    type: mongoose.Schema.Types.Mixed
    default: {}
  dpsir: mongoose.Schema.Types.Mixed
  theme: {type: mongoose.Schema.Types.ObjectId, ref: 'Theme'}
  type: String
  source: mongoose.Schema.Types.Mixed
  primary:
    type: Boolean,
    default: true
  owner: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
  description: String
)

# Mixins
pageModelMixin = require('../mixins/page_model.coffee')
updateIndicatorMixin = require('../mixins/update_indicator_data.coffee')

_.extend(indicatorSchema.methods, pageModelMixin.methods)
_.extend(indicatorSchema.statics, pageModelMixin.statics)
_.extend(indicatorSchema.methods, updateIndicatorMixin.methods)
_.extend(indicatorSchema.statics, updateIndicatorMixin.statics)

indicatorSchema.statics.CONDITIONS = {
  IS_PRIMARY: {primary: true}
}

replaceThemeNameWithId = (indicators) ->
  Theme = require('./theme').model

  deferred = Q.defer()

  getThemeFromTitle = (indicator, callback) ->
    Theme.findOrCreateByTitle(indicator.theme).then((theme) ->
      indicator.theme = theme._id
      callback(null, theme)
    ).catch(callback)

  async.map(indicators, getThemeFromTitle, (err, indicatorsWithThemes) ->
    if err?
      deferred.reject(err)

    deferred.resolve(indicatorsWithThemes)
  )

  return deferred.promise

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

    thePage.createSectionNarratives(sections)
  ).then( ->
    callback(null, theIndicator)
  ).fail( (err) ->
    callback(err)
  )

indicatorSchema.statics.seedData = (seedsPath) ->
  new Promise( (resolve, reject) ->
    unless fs.existsSync(seedsPath)
      throw new Error(
        "Unable to load indicator seed file, have you copied seeds from config/instances/ to config/seeds/?"
      )

    theIndicators = null
    Promise.promisify(fs.readFile, fs)(
      seedsPath, 'UTF8'
    ).then(
      JSON.parse
    ).then( (dummyIndicators) ->
      theIndicators = dummyIndicators
      replaceThemeNameWithId(dummyIndicators)
    ).then( ->
      async.map(theIndicators, createIndicatorWithSections, (err, indicators) ->
        if err?
          return reject(err)
        resolve(indicators)
      )
    )
  )

# Functions to aggregate the data bounds of different types of fields
boundAggregators = {}
boundAggregators.integer = (data, fieldName) ->
  bounds = {}
  bounds.min = _.min(data, (row) ->
    row[fieldName]
  )[fieldName]
  bounds.max = _.max(data, (row) ->
    row[fieldName]
  )[fieldName]

  return bounds

boundAggregators.date = boundAggregators.integer

indicatorSchema.statics.calculateBoundsForType = (fieldType, data, fieldName) ->
  if boundAggregators[fieldType]?
    return boundAggregators[fieldType](data, fieldName)
  else
    return null

indicatorSchema.methods.getIndicatorDataForCSV = (filters, callback) ->
  if arguments.length == 1
    callback = filters
    filters = {}

  @getIndicatorData(filters, (err, indicatorData) =>
    xAxis = @indicatorDefinition.xAxis
    yAxis = @indicatorDefinition.yAxis

    rows = [[xAxis, yAxis]]

    for row in indicatorData
      rows.push [
        row[xAxis].toString(),
        row[yAxis].toString()
      ]

    callback(err, rows)
  )


indicatorSchema.methods.hasData = ->
  new Promise((resolve, reject) =>
    @getIndicatorData( (err, data) ->
      if err?
        reject(err)
      else
        resolve(data.length > 0)
    )
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
      calculatedBounds = Indicator.calculateBoundsForType(field.type, data, field.name)
      if calculatedBounds?
        bounds[field.name] = calculatedBounds

    callback(null, bounds)
  )

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

CSV_HEADERS = ['Indicator', 'Theme', 'Collection Frequency', 'Date Updated']
indicatorSchema.methods.generateMetadataCSV = ->
  csvData = [CSV_HEADERS]

  attributes = []

  attributes.push @name

  Promise.promisify(
    @populate, @
  )('theme').then(=>

    attributes.push @theme?.title
    attributes.push @indicatorDefinition?.period

    headlineService = new HeadlineService(@)
    headlineService.getNewestHeadline()
  ).then((newestHeadline)=>
    xAxis = @indicatorDefinition?.xAxis

    if newestHeadline? and xAxis
      attributes.push newestHeadline[xAxis]
    else
      attributes.push ''

    csvData.push attributes
    csvData
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
  Promise.promisify(Indicator.find, Indicator)(
    conditions
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

    new Promise((resolve, reject) ->
      async.each indicators, addIndicatorIfHasData, (err) ->
        if err?
          reject(err)
        else
          resolve(indicatorsWithData)
    )
  )

indicatorSchema.statics.populatePages = (indicators) ->
  Promise.all(
    _.map(indicators, (indicator)->
      indicator.populatePage()
    )
  )

indicatorSchema.statics.convertNestedParametersToAssociationIds = (attributes) ->
  if attributes.theme? and typeof attributes.theme is 'object'
    attributes.theme = attributes.theme._id.toString()

  return attributes

Indicator = mongoose.model('Indicator', indicatorSchema)

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}
