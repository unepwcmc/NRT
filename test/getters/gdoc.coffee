assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
_ = require('underscore')

Indicator = require('../../models/indicator')
GDocGetter = require("../../getters/gdoc")
GoogleSpreadsheets = require("google-spreadsheets")

suite('Google Docs getter')

test("GDoc getter takes an Indicator and queries Google Spreadsheets
  with the indicator's spreadsheet id", (done) ->
  indicator = new Indicator(
    spreadsheet_key: '123'
    name: 'Key stakeholders identified'
  )

  expectedData = {
    '1': { value: 'Stakeholders' },
    '2': { value: 'Key stakeholders identified' },
    '3': { value: '0%' }
  }

  googleData = {
    cells: {
      '1': {
        '1': { value: 'Theme' },
        '2': { value: 'Indicator' },
        '3': { value: 'ProgressPercent' }
      },
      '2': expectedData
    }
  }

  cellsSpy = sinon.spy( (opts, callback) ->
    callback(null, googleData)
  )

  googleSpreadsheetStub = sinon.stub(GDocGetter::, 'queryGoogleSpreadsheet', (opts) ->
    Q.fcall( ->
      {
        worksheets: [
          cells: cellsSpy
        ]
      }
    )
  )

  new GDocGetter(
    indicator
  ).then( (data) ->
    assert.isTrue googleSpreadsheetStub.calledWith(key: '123'),
      "Expected GoogleSpreadsheets to be called with spreadsheet key '123'"

    assert.isTrue cellsSpy.calledOnce,
      "Expected GoogleSpreadsheets cells getter to be called"

    assert.deepEqual data, expectedData,
      "Expected Getter to return data from GoogleSpreadsheets request"

    done()
  ).fail( (err) ->
    console.error err
    done(err)
  )
)
