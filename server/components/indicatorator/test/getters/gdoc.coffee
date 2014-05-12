assert = require('chai').assert
sinon = require('sinon')
Promise = require('bluebird')
_ = require('underscore')

Indicator = require('../../../../models/indicator').model
GDocGetter = require("../../getters/gdoc")
GDocWrapper = require("../../../../lib/gdoc_wrapper")

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

  fakeGdoc = {
    'Data':  {
      '1': {
        '1': { value: 'Year'},
        '2': { value: 'Value'}
      }
      '2': {
        '1': { value: '1999' },
        '2': { value: '3858' }
      }
    }
  }

  gdocFetchStub = sinon.stub GDocWrapper, 'importByKey', ->
    then: (cb)->
      gdoc = new GDocWrapper({})
      sinon.stub(gdoc, 'getWorksheetData', (name) ->
        new Promise((resolve, reject) ->
          if name is 'Data'
            resolve(fakeGdoc[name])
          else
            reject(new Error("Expected the 'Data' worksheet to be requested,
            but got '#{name}' instead"))
        )
      )

      cb(gdoc)

  getter = new GDocGetter(
    indicator
  )

  getter.fetch().then( (data) ->
    assert.isTrue gdocFetchStub.calledWith(indicator.indicatorationConfig.spreadsheetKey),
      "Expected GoogleSpreadsheets to be called with spreadsheet key '123'"

    assert.deepEqual data, fakeGdoc['Data'],
      "Expected Getter to return data from GoogleSpreadsheets request"

    done()
  ).catch(
    done
  ).finally(->
    gdocFetchStub.restore()
  )
)