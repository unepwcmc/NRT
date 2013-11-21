# Indicator feed index
`GET /indicators/`
This route lists all the indicators in the service, with their metadata.

## Example
```json
[
  {
    "id": 1,
    "title": "Protected area coverage",
    "unit": "%",
    "description": "This describes the total protected area coverage as a percentage of the total area of the region"
  }, {
    "id": 2,
    "title": "GHG Emissions",
    "unit": "ug/mg3",
    "description": "Total GHG emissions are % of total emissions for that year"
  }
]
```

## Fields
* id - A unique identifier for the indicator
* title - The title of the indicator
* unit - The unit the value of the indicator is measured in
* description - A description of the indicator itself

# Indicator data feed
`GET /indicators/:id`

The data feed for an indicator. `:id` is populated from the IDs listed in the above route.

## Example
``` json
[ 
  {
    "geometry": {
     "x": 54.363716667000062,
     "y": 24.488927778000061
    },
    "periodStart": 1364778000000,
    "value": 100,
    "indicatorText": "Excellent"
  }, {
    "geometry": {
     "x": 54.363716667000062,
     "y": 26.488927778000061
    },
    "periodStart": 1364778000000,
    "value": 50,
    "indicatorText": "Poor"
  }
]
```

# Fields
* geometry - If the object has geometry, it should be represented as GeoJSON
* periodStart - The beginning of the period when the data was collected, as a unix epoch 
* value - The value of that indicator for the given period
* indicatorText - The description of what the value field means, e.g. 'Good', 'Below expected'...

