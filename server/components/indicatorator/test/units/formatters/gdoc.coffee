assert = require('chai').assert

GDocFormatter = require('../../../formatters/gdoc')

suite('Google Docs Spreadsheet Formatter')

test('Given a GoogleSpreadsheets query result, it formats it correctly', ->
  unformattedData = {
    '1':  {
      '1': { row: '1', col: '1', value: 'Year' },
      '2': { row: '1', col: '2', value: 'Value'}
    },
    '2': {
      '1': { row: '1', col: '1', value: '01/01/2013'},
      '2': { row: '1', col: '2', value: '0%'}
    }
    '3': {
      '1': { row: '1', col: '1', value: '01/04/2013'},
      '2': { row: '1', col: '2', value: '80%'}
    }
  }

  expectedResult = [
    {periodStart: '01/01/2013', value: '0%'},
    {periodStart: '01/04/2013', value: '80%'}
  ]

  actualResult = GDocFormatter(unformattedData)

  assert.deepEqual actualResult, expectedResult
)
