assert = require('chai').assert
sinon = require('sinon')
Promise = require('bluebird')
_ = require('underscore')

Indicator = require('../../../../models/indicator').model
GDocGetter = require("../../getters/gdoc")
GoogleSpreadsheets = require("google-spreadsheets")

suite('Google Docs getter')

test("GDoc stores a reference to the given indicator", ->
  indicator = {some: "data"}

  getter = new GDocGetter(
    indicator
  )

  assert.strictEqual(getter.indicator, indicator)
)

test("GDoc getter takes an Indicator and queries Google Spreadsheets
  with the indicator's spreadsheet id", (done) ->
  indicator = new Indicator(
    shortName: 'Key stakeholders identified'
    indicatorationConfig:
      spreadsheetKey: '123'
  )

  expectedData = {
    headers:
      '1': { value: 'Theme' },
      '2': { value: 'Indicator' },
      '3': { value: 'ProgressPercent' }
    data: [
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: '0%' }
    ]
  }

  googleData = {
    cells: {
      '1': expectedData.headers,
      '2': {
        '1': { value: 'Stakeholders' },
        '2': { value: 'Dat indicator' },
        '3': { value: '5%' }
      },
      '3': expectedData.data[0]
    }
  }

  cellsSpy = sinon.spy( (opts, callback) ->
    callback(null, googleData)
  )

  googleSpreadsheetStub = sinon.stub(GDocGetter::, 'queryGoogleSpreadsheet', (opts) ->
    Promise.resolve({
      worksheets: [
        cells: cellsSpy
      ]
    })
  )

  getter = new GDocGetter(
    indicator
  )

  getter.fetch().then( (data) ->
    assert.isTrue googleSpreadsheetStub.calledWith(key: '123'),
      "Expected GoogleSpreadsheets to be called with spreadsheet key '123'"

    assert.isTrue cellsSpy.calledOnce,
      "Expected GoogleSpreadsheets cells getter to be called"

    assert.deepEqual data, expectedData,
      "Expected Getter to return data from GoogleSpreadsheets request"

    googleSpreadsheetStub.restore()
    done()
  ).catch( (err) ->
    console.error err
    googleSpreadsheetStub.restore()
    done(err)
  )
)

test(".fetch returns all rows of a sub indicator", (done) ->
  indicator = new Indicator(
    shortName: 'Key stakeholders identified'
    indicatorationConfig:
      spreadsheetKey: '123'
  )

  expectedData = {
    headers:
      '1': { value: 'Theme' },
      '2': { value: 'Indicator' },
      '3': { value: 'SubIndicator' },
      '4': { value: 'ProgressPercent' }
    data: [{
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: '' },
      '4': { value: '0%' }
    }, {
      '1': { value: 'Stakeholders' },
      '2': { value: 'Key stakeholders identified' },
      '3': { value: 'Kuwait' },
      '4': { value: '0%' }
    }]
  }

  googleData = {
    cells: {
      '1': expectedData.headers,
      '2': {
        '1': { value: 'Stakeholders' },
        '2': { value: 'Dat indicator' },
        '3': { value: '5%' }
      },
      '3': expectedData.data[0],
      '4': expectedData.data[1],
      '5': {
        '1': { value: 'Stakeholders' },
        '2': { value: 'Dat indicator' },
        '3': { value: '5%' }
      },
    }
  }

  cellsSpy = sinon.spy( (opts, callback) ->
    callback(null, googleData)
  )

  googleSpreadsheetStub = sinon.stub(GDocGetter::, 'queryGoogleSpreadsheet', (opts) ->
    Promise.resolve({
      worksheets: [
        cells: cellsSpy
      ]
    })
  )

  getter = new GDocGetter(
    indicator
  )

  getter.fetch().then( (data) ->
    assert.isTrue googleSpreadsheetStub.calledWith(key: '123'),
      "Expected GoogleSpreadsheets to be called with spreadsheet key '123'"

    assert.isTrue cellsSpy.calledOnce,
      "Expected GoogleSpreadsheets cells getter to be called"

    assert.deepEqual data, expectedData,
      "Expected Getter to return data from GoogleSpreadsheets request"

    googleSpreadsheetStub.restore()
    done()
  ).catch( (err) ->
    console.error err
    googleSpreadsheetStub.restore()
    done(err)
  )
)
