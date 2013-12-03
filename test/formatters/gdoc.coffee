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
      '3': { value: '01/01/2013' },
      '4': { value: '01/04/2013' }
    data:
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: '0%' },
      '4': { value: '80%' }
  }

  expectedResult = [
    {periodStart: 1356998400000, value: 0},
    {periodStart: 1357257600000, value: 0.80}
  ]

  actualResult = GDocFormatter(expectedData)

  assert.deepEqual actualResult, expectedResult
)
