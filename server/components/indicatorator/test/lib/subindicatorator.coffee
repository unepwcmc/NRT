assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
SubIndicatorator = require '../../lib/subindicatorator'

suite('SubIndicatorator')

test('groupSubIndicatorsByPeriod groups rows with the same periodStart', ->
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

  groupedRows = SubIndicatorator.groupSubIndicatorsByPeriod(sampleRows)

  assert.lengthOf groupedRows[2010], 2,
    "Expected groupedRows[2010] to contain the 2 2010 values"
  assert.lengthOf _.where(groupedRows[2010], {station: 'station 2'}), 1,
    "Expected groupedRows[2010] to contain the station 2 record"

  assert.lengthOf groupedRows[2011], 1,
    "Expected groupedRows[2011] to contain the 1 2011 value"
  assert.lengthOf _.where(groupedRows[2011], {station: 'station 2'}), 0,
    "Expected groupedRows[2010] to not contain the station 2 record"
)

test('groupSubIndicatorsUnderAverageIndicators when the indicator definition
includes a reduce field it averages the text field and includes the child data
under the reduce field attribute', ->
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

  stubbedAverageIndicator =
    text: "Good"
    value: "for 4 of 5"
  calculateAverageStub = sinon.stub(SubIndicatorator, 'calculateAverageIndicator', ->
    stubbedAverageIndicator
  )

  try
    results = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(sampleRows, indicatorDefinition)

    firstResult = results[0]

    assert.strictEqual calculateAverageStub.callCount, 1,
      "Expected the SubIndicatorator.calculateAverageIndicator to be called once"

    assert.isTrue calculateAverageStub.calledWith(sampleRows, indicatorDefinition),
      "Expected the SubIndicatorator.calculateAverageIndicator to be called
      with the sub indicators and the indicator definition"

    assert.strictEqual firstResult.text, stubbedAverageIndicator.text,
      "Expected the averaged text to be returned"

    assert.strictEqual firstResult.value, stubbedAverageIndicator.value,
      "Expected the averaged value to be returned"

    assert.deepEqual firstResult.station, sampleRows,
      "Expected the results to include the reduce field as an attribute"

    assert.equal firstResult.periodStart, 2010,
      "Expected the results to include period start of the sub indicators"
  finally
    calculateAverageStub.restore()
)

test('.groupSubIndicatorsUnderAverageIndicators groups data with subindicators
 on the given reduce field', ->
  indicatorData = [{
    geometry: {
      x: 54.374894503000064,
      y: 24.428641001000074
    },
    OBJECTID: 1,
    station: "Palace Beach",
    periodStart: 1356998400000,
    value: 37,
    text: "GOOD"
  }, {
    geometry: {
        x: 54.30470040400007,
        y: 24.465522647000057
    },
    OBJECTID: 3,
    station: "Emirates Palace Beach",
    periodStart: 1364774400000,
    value: 50,
    text: "GOOD"
  }, {
    geometry: {
        x: 54.30470040400007,
        y: 24.465522647000057
    },
    OBJECTID: 15,
    station: "Emirates Palace Beach",
    periodStart: 1356998400000,
    value: 160,
    text: "BAD"
  }, {
    geometry: {
        x: 54.374894503000064,
        y: 24.428641001000074
    },
    OBJECTID: 25,
    station: "Palace Beach",
    periodStart: 1364774400000,
    value: 400,
    text: "BAD"
  }]

  expectedResult = [{
    text: "GOOD",
    value: "1 of 2",
    station: [{
      geometry: {
        x: 54.374894503000064,
        y: 24.428641001000074
      },
      OBJECTID: 1,
      station: "Palace Beach",
      periodStart: 1356998400000,
      value: 37,
      text: "GOOD"
    }, {
      geometry: {
          x: 54.30470040400007,
          y: 24.465522647000057
      }
      OBJECTID: 15,
      station: "Emirates Palace Beach",
      periodStart: 1356998400000,
      value: 160,
      text: "BAD"
    }],
    periodStart: 1356998400000
  },
  {
    text: "GOOD",
    value: "1 of 2",
    station: [{
        geometry: {
            x: 54.30470040400007,
            y: 24.465522647000057
        }
        OBJECTID: 3,
        station: "Emirates Palace Beach",
        periodStart: 1364774400000,
        value: 50,
        text: "GOOD",
    }, {
        geometry: {
          x: 54.374894503000064,
          y: 24.428641001000074
        }
        OBJECTID: 25,
        station: "Palace Beach",
        periodStart: 1364774400000,
        value: 400,
        text: "BAD",
      }],
    periodStart: 1364774400000
  }]

  indicatorDefinition =
    valueField: 'value'
    reduceField: "station"

  result = SubIndicatorator.groupSubIndicatorsUnderAverageIndicators(
    indicatorData, indicatorDefinition
  )

  assert.deepEqual result, expectedResult,
    "Expected the sub indicators to be grouped"
)

test("#calculateAverageIndicator given an array of subIndicators returns an object
 with a 'text' attribute set to the mode text of the sub indicators", ->
  indicatorDefinition =
    valueField: 'amount'

  subIndicators = [{
    text: "Good"
  }, {
    text: "Good"
  }, {
    text: "Poor"
  }]

  averageIndicator = SubIndicatorator.calculateAverageIndicator(
    subIndicators, indicatorDefinition
  )

  assert.strictEqual averageIndicator.text, "Good",
    "Expected the text value to be set to the mode text ('Good')"
)

test("#calculateAverageIndicator given an array of subIndicators returns an object
 with a 'value' attribute set to the count of sub indicators with the mode text", ->
  indicatorDefinition =
    valueField: 'amount'

  subIndicators = [{
    text: "Poor"
  }, {
    text: "Good"
  }, {
    text: "Good"
  }]

  averageIndicator = SubIndicatorator.calculateAverageIndicator(
    subIndicators, indicatorDefinition
  )

  assert.strictEqual averageIndicator.amount, "2 of 3",
    "Expected the amount to be set to the count of mode text sub indicators (2 of 3)"
)
