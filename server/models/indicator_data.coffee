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

indicatorDataSchema.statics.convertDataToHeadline = (data) ->
  data = IndicatorData.parseDateInHeadlines(data)
  data = IndicatorData.roundHeadlineValues(data)
  return data

indicatorDataSchema.statics.parseDateInHeadlines = (headlines) ->
  for headline in headlines
    headline.periodEnd = moment("#{headline.year}")
      .add('years', 1).subtract('days', 1).format("D MMM YYYY")

  return headlines

indicatorDataSchema.statics.roundHeadlineValues = (headlines) ->
  for headline in headlines
    unless isNaN(headline.value)
      headline.value = Math.round(headline.value*10)/10

  return headlines

IndicatorData = mongoose.model('IndicatorData', indicatorDataSchema)

module.exports = {
  schema: indicatorDataSchema,
  model: IndicatorData
}

