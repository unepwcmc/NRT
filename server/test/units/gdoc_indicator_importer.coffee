assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
Promise = require 'bluebird'

GDocIndicatorImporter = require '../../lib/gdoc_indicator_importer'
GDocWrapper = require '../../lib/gdoc_wrapper'

suite('GdocIndicatorImporter')

test('#import when given a valid spreadsheet key
  pulls that spreadsheet and creates a new indicator with
  attributes from the spreadsheet', (done) ->

  indicatorDefinition =
    name: 'Fish Landings'
    theme: 'Coastal'
    unit: 'landings'
    ranges: [
      {threshold: 50, text: 'Good'},
      {threshold: 0, text: 'Bad'}
    ]

  fakeGdoc = {
    'Definition':
      '1': {
        '1': { row: '1', col: '1', value: 'What\'s the name of this indicator?' },
        '2': { row: '1', col: '2', value: 'What theme does this indicator relate to?'},
        '3': { row: '1', col: '3', value: 'What unit does the indicator value use?'}
      },
      '2': {
        '1': { row: '1', col: '1', value: indicatorDefinition.name},
        '2': { row: '1', col: '2', value: indicatorDefinition.theme},
        '3': { row: '1', col: '3', value: indicatorDefinition.unit}
      }
    'Range':
      '1': {
        '1': { row: '1', col: '1', value: 'Threshold' },
        '2': { row: '1', col: '2', value: 'Text'}
      },
      '2': {
        '1': { row: '1', col: '1', value: indicatorDefinition.ranges[0].threshold},
        '2': { row: '1', col: '2', value: indicatorDefinition.ranges[0].text}
      }
      '2': {
        '1': { row: '1', col: '1', value: indicatorDefinition.ranges[1].threshold},
        '2': { row: '1', col: '2', value: indicatorDefinition.ranges[1].text}
      }
  }

  gdocFetchStub = sinon.stub GDocWrapper, 'importByKey', ->
    then: (cb)->
      gdoc = new GDocWrapper({})
      sinon.stub(gdoc, 'getWorksheetData', (name) ->
        new Promise((resolve) ->
          resolve(fakeGdoc[name])
        )
      )

      cb(gdoc)

  key = '12-n-xlzFlT3T1dScfaI7a7ZnhEILbtSCjXSNKbfLJEI'
  GDocIndicatorImporter.import(key).then( (createdIndicator)->

    try
      assert.strictEqual gdocFetchStub.callCount, 1,
        "Expected fetch to be called"

      assert.isTrue gdocFetchStub.calledWith(key),
        "Expected fetch to be called with the given spreadsheet key"

      done()
    catch err
      done(err)

  ).error((err)->
    done(err)
  ).finally(->
    gdocFetchStub.restore()
  )
)
