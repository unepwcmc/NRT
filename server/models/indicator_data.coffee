mongoose = require('mongoose')
fs = require('fs')
Q = require 'q'

indicatorDataSchema = mongoose.Schema(
  indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  data: mongoose.Schema.Types.Mixed
)

indicatorDataSchema.statics.seedData = (indicators) ->
  deferred = Q.defer()

  IndicatorData.count(null, (error, count) ->
    if error?
      deferred.reject(error)

    if count is 0
      # Grab indcator data from disk
      dummyIndicatorData = JSON.parse(
        fs.readFileSync("#{process.cwd()}/lib/indicator_data.json", 'UTF8')
      )

      # Add indicator IDs to dummy data
      for indicatorData, index in dummyIndicatorData
        dummyIndicatorData[index].indicator = indicators[indicators.length%index]

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

