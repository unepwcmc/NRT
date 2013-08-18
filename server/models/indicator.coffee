mongoose = require('mongoose')
request = require('request')
fs = require('fs')
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

indicatorSchema.methods.getIndicatorData = (callback) ->

  IndicatorData.findOne enviroportalId: @indicatorDefinition.enviroportalId, (err, res) ->
    if err?
      console.error err
      callback err
    else
      callback null, res.data
 

Indicator = mongoose.model('Indicator', indicatorSchema)

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}

