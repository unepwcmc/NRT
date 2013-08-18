mongoose = require('mongoose')
fs = require('fs')

indicatorDataSchema = mongoose.Schema(
  enviroportalId: Number
  data: mongoose.Schema.Types.Mixed
)

indicatorDataSchema.statics.seedData = (callback) ->
  # Seed some indicators
  dummyIndicatorData = JSON.parse(
    fs.readFileSync("#{process.cwd()}/lib/indicator_data.json", 'UTF8')
  )

  IndicatorData.count(null, (error, count) ->
    if error?
      console.error error
      return callback(error) 

    if count == 0
      IndicatorData.create(dummyIndicatorData, (error, results) ->
        if error?
          console.error error
          return callback(error) 
        else
          return callback(null, results)
      )
    else
      callback()
  )

IndicatorData = mongoose.model('IndicatorData', indicatorDataSchema)

module.exports = {
  schema: indicatorDataSchema,
  model: IndicatorData
}

