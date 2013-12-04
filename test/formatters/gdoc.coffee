assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
_ = require('underscore')

GDocFormatter = require('../../formatters/gdoc')

suite('Google Docs Spreadsheet Formatter')

test('Given a GoogleSpreadsheets query result, it formats it correctly', ->
  expectedData = {
    headers:
      '1': { value: 'Theme' },
      '2': { value: 'Indicator' },
      '3': { value: 'SubIndicator' },
      '4': { value: '01/01/2013' },
      '5': { value: '01/04/2013' }
    data: [
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: '' },
      '4': { value: '0%' },
      '5': { value: '80%' }
    ]
  }

  expectedResult = [
    {periodStart: 1356998400000, value: 0},
    {periodStart: 1357257600000, value: 0.80}
  ]

  actualResult = GDocFormatter(expectedData)

  assert.deepEqual actualResult, expectedResult
)

test('Given a GoogleSpreadsheets query result with sub indicators,
  it formats it correctly', ->
  expectedData = {
    headers:
      '1': { value: 'Theme' },
      '2': { value: 'Indicator' },
      '3': { value: 'SubIndicator' },
      '4': { value: '01/01/2013' },
      '5': { value: '01/04/2013' }
    data: [{
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: '' },
      '4': { value: '10%' },
      '5': { value: '80%' }
    }, {
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: 'Kuwait' },
      '4': { value: '0%' },
      '5': { value: '80%' }
    }, {
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: 'BP' },
      '4': { value: '20%' },
      '5': { value: '80%' }
    }]
  }

  expectedResult = [{
    periodStart: 1356998400000, value: 0.1, subIndicator: [
      {subIndicator: 'Kuwait', value: 0, periodStart: 1356998400000},
      {subIndicator: 'BP', value: 0.2, periodStart: 1356998400000}
    ]
  }, {
    periodStart: 1357257600000, value: 0.80, subIndicator: [
      {subIndicator: 'Kuwait', value: 0.8, periodStart: 1357257600000},
      {subIndicator: 'BP', value: 0.8, periodStart: 1357257600000}
    ]
  }]

  actualResult = GDocFormatter(expectedData)

  assert.deepEqual actualResult, expectedResult
)
