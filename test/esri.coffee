assert = require('chai').assert
_ = require('underscore')
Esri = require '../indicatorators/esri'

suite('ESRI indicatorator')

test('groupRowsByPeriod groups rows with the same periodStart', ->
  sampleRows = [{
    station: "station 1"
    periodStart: 2010
    text: "Good"
  }, {
    station: "station 2"
    periodStart: 2010
    text: "Good"
  }, {
    station: "station 1"
    periodStart: 2011
    text: "Poor"
  }]

  groupedRows = Esri.groupRowsByPeriod(sampleRows)

  assert.lengthOf groupedRows[2010], 2,
    "Expected groupedRows[2010] to contain the 2 2010 values"
  assert.lengthOf _.where(groupedRows[2010], {station: 'station 2'}), 1,
    "Expected groupedRows[2010] to contain the station 2 record"

  assert.lengthOf groupedRows[2011], 1,
    "Expected groupedRows[2011] to contain the 1 2011 value"
  assert.lengthOf _.where(groupedRows[2011], {station: 'station 2'}), 0,
    "Expected groupedRows[2010] to not contain the station 2 record"
)

test('averageRows when the indicator definition includes a reduce field
  it averages the text field and includes the child data under the reduce field
  attribute', ->
  sampleRows = [{
    station: "station 1"
    periodStart: 2010
    text: "Good"
  }, {
    station: "station 2"
    periodStart: 2010
    text: "Good"
  }, {
    station: "station 3"
    periodStart: 2010
    text: "Poor"
  }]

  indicatorDefinition =
    valueField: 'amount'
    reduceField: 'station'

  results = Esri.averageRows(sampleRows, indicatorDefinition)

  firstResult = results[0]
  assert.strictEqual firstResult.text, "Good",
    "Expected the results to use the mode text"

  assert.strictEqual firstResult.amount, "-",
    "Expected the amount to be '-', as we can't average the amounts meaningfully"

  assert.property firstResult, 'station',
    "Expected the results to include the reduce field as an attribute"
)
