mongoose = require('mongoose')
request = require('request')
fs = require('fs')
_ = require('underscore')
IndicatorData = require('./indicator_data').model

indicatorSchema = mongoose.Schema(
  title: String
  description: String
  indicatorDefinition: mongoose.Schema.Types.Mixed
)

indicatorSchema.statics.seedData = (callback) ->
  # Seed some indicators
  dummyIndicators = JSON.parse(
    fs.readFileSync("#{process.cwd()}/lib/sample_indicators.json", 'UTF8')
  )

  Indicator.count(null, (error, count) ->
    if error?
      console.error error
      return callback(error) 

    if count == 0
      Indicator.create(dummyIndicators, (error, results) ->
        if error?
          console.error error
          return callback(error)
        else
          return callback(null, results)
      )
    else
      callback()
  )

indicatorSchema.methods.getIndicatorData = (filters, callback) ->
  if arguments.length == 1
    callback = filters
    filters = {}

  IndicatorData.findOne enviroportalId: @indicatorDefinition.enviroportalId, (err, res) ->
    if err?
      console.error err
      callback err
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

indicatorSchema.methods.calculateIndicatorDataBounds = (callback) ->
  @getIndicatorData((error, data) =>
    bounds = {}

    unless @indicatorDefinition.fields?
      return console.log("Indicator definition does not list fields, cannot get bounds")

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

Indicator = mongoose.model('Indicator', indicatorSchema)

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}

