mongoose = require('mongoose')
fs = require('fs')
Q = require 'q'

indicatorDataSchema = mongoose.Schema(
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  data: mongoose.Schema.Types.Mixed
)

findIndicatorWithShortName = (indicators, shortName) ->
  for indicator in indicators
    return indicator if indicator.short_name is shortName

  return null

dateReviver = (key, value) ->
  if key is 'date'
    return new Date(value)
  else
    return value

indicatorDataSchema.statics.seedData = (indicators) ->
  deferred = Q.defer()

  IndicatorData.count(null, (error, count) ->
    if error?
      deferred.reject(error)

    if count is 0
      # Grab indcator data from disk
      dummyIndicatorData = JSON.parse(
        fs.readFileSync("#{process.cwd()}/lib/indicator_data.json", 'UTF8'),
        dateReviver
      )

      # Add indicator IDs to dummy data
      for indicatorData, index in dummyIndicatorData
        shortName = dummyIndicatorData[index].indicator
        dummyIndicatorData[index].indicator = findIndicatorWithShortName(indicators, shortName)

      IndicatorData.create(dummyIndicatorData, (error, results) ->
        if error?
          deferred.reject(error)
        else
          deferred.resolve(results)
      )
    else
      deferred.resolve()
  )

  return deferred.promise

IndicatorData = mongoose.model('IndicatorData', indicatorDataSchema)

module.exports = {
  schema: indicatorDataSchema,
  model: IndicatorData
}

