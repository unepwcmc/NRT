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

  spreadsheetKey = '12-n-xlzFlT3T1dScfaI7a7ZnhEILbtSCjXSNKbfLJEI'

  fakeGdoc = {
    'Definition': {indicator: 'Definition'}
    'Ranges': {range: 'Definitions'}
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
            reject(new Error("Expected the 'Definition' or 'Ranges' worksheet to be requested,
            but got '#{name}' instead"))
        )
      )

      cb(gdoc)

  setDefinitionStub = sandbox.stub(
    GDocIndicatorImporter::, 'setDefinitionFromWorksheet', ->
      assert.strictEqual(
        @indicatorProperties.indicatorationConfig.spreadsheet_key,
        spreadsheetKey,
        "Expected the spreadsheet key to be set"
      )
  )
  setRangesStub = sandbox.stub(
    GDocIndicatorImporter::, 'setRangesFromWorksheet', ->
  )
  createIndicatorStub = sandbox.stub(
    GDocIndicatorImporter::, 'createIndicator', ->
      Promise.resolve()
  )

  GDocIndicatorImporter.import(spreadsheetKey).then( (createdIndicator)->

    try
      assert.strictEqual gdocFetchStub.callCount, 1,
        "Expected fetch to be called"

      assert.isTrue gdocFetchStub.calledWith(spreadsheetKey),
        "Expected fetch to be called with the given spreadsheet key"

      assert.strictEqual setDefinitionStub.callCount, 1,
        "Expected gdocIndicatorBuilder.setDefinitionFromWorksheet to be called"

      setDefinitionArg = setDefinitionStub.getCall(0).args[0]
      assert.deepEqual setDefinitionArg, fakeGdoc.Definition,
        "Expected gdocIndicatorBuilder.setDefinitionFromWorksheet to be called
         with the indicator definition worksheet"

      assert.strictEqual setRangesStub.callCount, 1,
        "Expected gdocIndicatorBuilder.setRangesFromWorksheet to be called"

      setRangesArg = setRangesStub.getCall(0).args[0]
      assert.deepEqual setRangesArg, fakeGdoc.Ranges,
        "Expected gdocIndicatorBuilder.setRangesFromWorksheet to be called
         with the ranges worksheet"

      assert.strictEqual createIndicatorStub.callCount, 1,
        "Expected gdocIndicatorBuilder.createIndicator to be called"

      done()
    catch err
      done(err)

  ).error((err)->
    done(err)
  ).finally(->
    sandbox.restore()
  )
)

test('.setDefinitionFromWorksheet builds the indicatorProperties from
  from the given definition worksheet', (done) ->
  key = 574289
  builder = new GDocIndicatorImporter(key)

  indicatorThemeTitle = 'Coastal'
  indicatorProperties =
    short_name: 'Fish Landings'
    title: 'Fish Landings'
    indicatorDefinition:
      unit: 'landings'
      short_unit: 'landings'
    indicatorationConfig:
      source: 'gdoc'
      spreadsheet_key: key

  definitionWorksheet =
    '1': {
      '1': { row: '1', col: '1', value: 'What\'s the name of this indicator?' },
      '2': { row: '1', col: '2', value: 'What theme does this indicator relate to?'},
      '3': { row: '1', col: '3', value: 'What unit does the indicator value use?'}
    },
    '2': {
      '1': { row: '1', col: '1', value: indicatorProperties.short_name},
      '2': { row: '1', col: '2', value: indicatorThemeTitle},
      '3': { row: '1', col: '3', value: indicatorProperties.indicatorDefinition.unit}
    }

  helpers.createThemesFromAttributes(
    [{title: indicatorThemeTitle}]
  ).get(0).then((theme) ->
    indicatorProperties.theme = theme._id
    builder.setDefinitionFromWorksheet(definitionWorksheet)
  ).then( ->
    assert.deepEqual builder.indicatorProperties, indicatorProperties,
      "Expected the indicator properties to be set from the definition worksheet"
    done()
  ).catch(done)

)

test('.setRangesFromWorksheet builds the indicatorProperties from
  from the given ranges worksheet', ->
  key = 574289
  builder = new GDocIndicatorImporter(key)

  indicatorProperties =
    indicatorationConfig:
      source: 'gdoc'
      spreadsheet_key: key
      range: [
        {threshold: 0, text: 'Bad'}
        {threshold: 0.5, text: 'Good'}
      ]

  rangesWorksheet =
    '1': {
      '1': { row: '1', col: '1', value: 'Threshold' },
      '2': { row: '1', col: '2', value: 'Text'}
    },
    '2': {
      '1': {
        row: '1',
        col: '1',
        value: indicatorProperties.indicatorationConfig.range[0].threshold
      },
      '2': {
        row: '1',
        col: '2',
        value: indicatorProperties.indicatorationConfig.range[0].text
      }
    }
    '3': {
      '1': {
        row: '1',
        col: '1',
        value: indicatorProperties.indicatorationConfig.range[1].threshold
      },
      '2': {
        row: '1',
        col: '2',
        value: indicatorProperties.indicatorationConfig.range[1].text
      }
    }

  builder.setRangesFromWorksheet(rangesWorksheet)

  assert.deepEqual builder.indicatorProperties, indicatorProperties,
    "Expected the indicator properties to be set from the ranges worksheet"
)