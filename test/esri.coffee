assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
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

test('averageRows when the indicator definition includes a reduce field
sets the value field to the count of the mode text', ->
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

test('addIndicatorTextToData adds the correct indicator text', ->
  calculateIndicatorTextStub = sinon.stub(Esri, '_calculateIndicatorText', () ->
    return 'Great'
  )

  rows = [
    {"OBJECTID":1,"periodStar":1364774400000,"value":6,"station":"Liwa Oasis","text":"YES"}
  ]
  indicatorDefinition =
    valueField: 'value'

  results = Esri.addIndicatorTextToData(rows, 'CODE', indicatorDefinition)

  assert.lengthOf results, 1, "Expected no rows to be removed"

  result = results[0]
  assert.strictEqual result.text, 'Great', "Expected the text value to be set to 'great'"

  calculateIndicatorTextStub.restore()
)

test('#getFeatureAttributesFromData maps merged attributes and geometry into a single object', ->
  data =
    features: [{
      geometry: {x: 5, y: 3}
      attributes:
        name: 'boat'
    }]

  mappedAttributesFromData = Esri.getFeatureAttributesFromData(data)

  assert.lengthOf mappedAttributesFromData, 1,
    "Expected the number of rows not to be changed"

  row = mappedAttributesFromData[0]
  assert.property row, 'geometry',
    "Expected the geometry attribute to be at the top level"

  assert.property row, 'name',
    "Expected the name attribute to be at the top level"
)
