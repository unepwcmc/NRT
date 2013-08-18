mongoose = require('mongoose')
definitions = require('../lib/indicator_definitions')
request = require('request')
fs = require('fs')

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
  dummyExternalData = JSON.parse(
    fs.readFileSync("#{process.cwd()}/lib/indicator_definitions.json", 'UTF8')
  ).indicators

  for indicatorAttributes, index in dummyIndicators 
    externalIndex = index % dummyExternalData.length
    indicatorAttributes.indicatorDefinition = dummyExternalData[externalIndex]

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
  callback null, {
   "displayFieldName": "Name",
   "fieldAliases": {
    "Shape.area": "Shape.area",
    "Name": "Name of Protected Area"
   },
   "fields": [
    {
     "name": "Shape.area",
     "type": "esriFieldTypeDouble",
     "alias": "Shape.area"
    },
    {
     "name": "Name",
     "type": "esriFieldTypeString",
     "alias": "Name of Protected Area",
     "length": 255
    }
   ],
   "features": [
    {
     "attributes": {
      "Shape.area": 0.0078117814322679578,
      "Name": "Jabel Hafit National Park"
     }
    },
    {
     "attributes": {
      "Shape.area": 0.0004111909721562731,
      "Name": "Wathba Wetland Reserve"
     }
    },
    {
     "attributes": {
      "Shape.area": 0.69648989049094367,
      "Name": "Arabian Oryx Protected Area"
     }
    },
    {
     "attributes": {
      "Shape.area": 0.068706831837464608,
      "Name": "Houbara Protected Area"
     }
    }
   ]
  }

Indicator = mongoose.model('Indicator', indicatorSchema)

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}

