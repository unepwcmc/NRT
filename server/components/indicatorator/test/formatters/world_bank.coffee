assert = require('chai').assert

WorldBankFormatter = require('../../formatters/world_bank')

suite('WorldBank Formatter')

test('formats the given data correctly', ->
  rawData = [
    {},
    [
      {
        "indicator": {
          "id": "AG.LND.FRST.ZS",
          "value": "Forest area (% of land area)"
        },
        "country": {
          "id": "MU",
          "value": "Mauritius"
        },
        "value": "21",
        "decimal": "0",
        "date": "1968"
      },
      {
        "indicator": {
          "id": "AG.LND.FRST.ZS",
          "value": "Forest area (% of land area)"
        },
        "country": {
          "id": "MU",
          "value": "Mauritius"
        },
        "value": "17.2512315270936",
        "decimal": "1",
        "date": "1969"
      }
    ]
  ]

  expectedResult = [{
    "value": "21",
    "date": "1968"
  }, {
    "value": "17.2512315270936",
    "date": "1969"
  }]

  actualResult = WorldBankFormatter(rawData)

  assert.deepEqual actualResult, expectedResult
)
