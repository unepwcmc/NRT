mongoose = require('mongoose')
definitions = require('../lib/indicator_definitions')
request = require('request')


indicatorSchema = mongoose.Schema(
  title: String
  description: String
)

Indicator = mongoose.model('Indicator', indicatorSchema)

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

module.exports = {
  schema: indicatorSchema,
  model: Indicator
}

