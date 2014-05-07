assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
Promise = require 'bluebird'

GDocIndicatorImporter = require '../../lib/gdoc_indicator_importer'
GDocWrapper = require '../../lib/gdoc_wrapper'
Indicator = require('../../models/indicator').model

suite('GdocIndicatorImporter')

test('#import when given a valid spreadsheet key
  pulls that spreadsheet and creates a new indicator with
  attributes from the spreadsheet', (done) ->

  indicatorDefinition =
    name: 'Fish Landings'
    theme: 'Coastal'
    unit: 'landings'
    indicatorationConfig:
      source: 'gdoc'
      spreadsheet_key: '12-n-xlzFlT3T1dScfaI7a7ZnhEILbtSCjXSNKbfLJEI'
      range: [
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
    'Ranges':
      '1': {
        '1': { row: '1', col: '1', value: 'Threshold' },
        '2': { row: '1', col: '2', value: 'Text'}
      },
      '2': {
        '1': {
          row: '1',
          col: '1',
          value: indicatorDefinition.indicatorationConfig.range[0].threshold
        },
        '2': {
          row: '1',
          col: '2',
          value: indicatorDefinition.indicatorationConfig.range[0].text
        }
      }
      '3': {
        '1': {
          row: '1',
          col: '1',
          value: indicatorDefinition.indicatorationConfig.range[1].threshold
        },
        '2': {
          row: '1',
          col: '2',
          value: indicatorDefinition.indicatorationConfig.range[1].text
        }
      }
  }

  sandbox = sinon.sandbox.create()

  gdocFetchStub = sandbox.stub GDocWrapper, 'importByKey', ->
    then: (cb)->
      gdoc = new GDocWrapper({})
      sandbox.stub(gdoc, 'getWorksheetData', (name) ->
        new Promise((resolve, reject) ->
          if name in ['Definition', 'Ranges']
            resolve(fakeGdoc[name])
          else
            reject(new Error("Expected the 'Definition' worksheet to be requested,
            but got '#{name}' instead"))
        )
      )

      cb(gdoc)

  indicatorBuildStub = sandbox.stub(Indicator, 'buildWithDefaults', (definition)->
    save: (cb)-> cb(null, true)
  )


  key = indicatorDefinition.indicatorationConfig.spreadsheet_key

  GDocIndicatorImporter.import(key).then( (createdIndicator)->

    try
      assert.strictEqual gdocFetchStub.callCount, 1,
        "Expected fetch to be called"

      assert.isTrue gdocFetchStub.calledWith(key),
        "Expected fetch to be called with the given spreadsheet key"

      assert.strictEqual indicatorBuildStub.callCount, 1,
        "Expected Indicator.buildWithDefaults to be called"

      indicatorBuildArgs = indicatorBuildStub.getCall(0).args[0]
      assert.deepEqual indicatorBuildArgs, indicatorDefinition,
        "Expected Indicator.buildWithDefaults to be called with the
          spreadsheet definition"

      done()
    catch err
      done(err)

  ).error((err)->
    done(err)
  ).finally(->
    sandbox.restore()
  )
)
