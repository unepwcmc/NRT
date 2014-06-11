assert = require('chai').assert
nodeXlsx = require('node-xlsx')
helpers = require '../helpers'
sinon = require 'sinon'
Promise = require 'bluebird'

Theme = require('../../models/theme').model
XlsxIndicatorImporter = require '../../lib/xlsx_indicator_importer'
Indicator = require('../../models/indicator').model

suite('XslxIndicatorImporter')

test('#import when given a valid file path
  reads that spreadsheet and creates a new indicator with
  attributes from the spreadsheet', (done) ->

  spreadsheetPath = 'somewhere/over/the/rainbow.xlsx'


  sandbox = sinon.sandbox.create()

  fakeXlsx =
    worksheets: [
      {name: 'Definition'}, {name: 'Ranges'}
    ]
  nodeXlsxParseStub = sandbox.stub(nodeXlsx, 'parse', -> fakeXlsx)

  setDefinitionStub = sandbox.stub(
    XlsxIndicatorImporter::, 'setDefinitionFromWorksheet', ->
      Promise.resolve()
  )
  setRangesStub = sandbox.stub(
    XlsxIndicatorImporter::, 'setRangesFromWorksheet', ->
  )
  createOrUpdateStub = sandbox.stub(
    XlsxIndicatorImporter::, 'createOrUpdateIndicator', ->
      Promise.resolve()
  )

  XlsxIndicatorImporter.import(spreadsheetPath).then( (createdIndicator)->

    try
      assert.strictEqual nodeXlsxParseStub.callCount, 1,
        "Expected fetch to be called"

      assert.isTrue nodeXlsxParseStub.calledWith(spreadsheetPath),
        "Expected fetch to be called with the given spreadsheetPath"

      assert.strictEqual setDefinitionStub.callCount, 1,
        "Expected gdocIndicatorBuilder.setDefinitionFromWorksheet to be called"

      setDefinitionArg = setDefinitionStub.getCall(0).args[0]
      assert.deepEqual setDefinitionArg, fakeXlsx.Definition,
        "Expected gdocIndicatorBuilder.setDefinitionFromWorksheet to be called
         with the indicator definition worksheet"

      assert.strictEqual setRangesStub.callCount, 1,
        "Expected gdocIndicatorBuilder.setRangesFromWorksheet to be called"

      setRangesArg = setRangesStub.getCall(0).args[0]
      assert.deepEqual setRangesArg, fakeXlsx.Ranges,
        "Expected gdocIndicatorBuilder.setRangesFromWorksheet to be called
         with the ranges worksheet"

      assert.strictEqual createOrUpdateStub.callCount, 1,
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

test('.setDefinitionFromWorksheet builds the indicatorProperties
  from the given definition worksheet', (done) ->

  importer = new XlsxIndicatorImporter()

  indicatorThemeTitle = 'Coastal'
  indicatorProperties =
    shortName: 'Fish Landings'
    name: 'Fish Landings'
    indicatorDefinition:
      unit: 'landings'
      shortUnit: 'landings'
    indicatorationConfig:
      source: 'xlsx'


  definitionWorksheet = [
   [
      { value: 'What\'s the name of this indicator?', formatCode: 'General' },
      { value: 'What theme does this indicator relate to?', formatCode: 'General' },
      { value: 'What unit does the indicator value use?', formatCode: 'General' }
    ], [
      { value: indicatorProperties.shortName, formatCode: 'General' },
      { value: indicatorThemeTitle, formatCode: 'General' },
      { value: indicatorProperties.indicatorDefinition.unit, formatCode: 'General' }
    ]
  ]

  helpers.createThemesFromAttributes(
    [{title: indicatorThemeTitle}]
  ).get(0).then( (theme) ->
    indicatorProperties.theme = theme._id
    Promise.promisify(theme.save, theme)()
  ).then( ->
    importer.setDefinitionFromWorksheet(definitionWorksheet)
  ).then( ->
    assert.deepEqual importer.indicatorProperties, indicatorProperties,
      "Expected the indicator properties to be set from the definition worksheet"
    done()
  ).catch(done)

)

test('.setRangesFromWorksheet builds the indicatorProperties from
  from the given ranges worksheet', ->
  importer = new XlsxIndicatorImporter()

  indicatorProperties =
    indicatorationConfig:
      source: 'xlsx'
      range: [
        {threshold: 0, text: 'Bad'}
        {threshold: 0.5, text: 'Good'}
      ]

  rangesWorksheet = [
    [
      { value: 'Threshold' },
      { value: 'Text'}
    ], [
      { value: indicatorProperties.indicatorationConfig.range[0].threshold },
      { value: indicatorProperties.indicatorationConfig.range[0].text }
    ], [
      { value: indicatorProperties.indicatorationConfig.range[1].threshold },
      { value: indicatorProperties.indicatorationConfig.range[1].text }
    ]
  ]

  importer.setRangesFromWorksheet(rangesWorksheet)

  assert.deepEqual importer.indicatorProperties, indicatorProperties,
    "Expected the indicator properties to be set from the ranges worksheet"
)

test('.createOrUpdateIndicator when there is no existing indicator
  with the given spreadsheet key, it creates a new indicator', (done)->
  theKey = 'hat'
  importer = new XlsxIndicatorImporter(theKey)

  importer.createOrUpdateIndicator().then(->
    Promise.promisify(Indicator.findOne, Indicator)({})
  ).then( (indicator)->
    assert.isNotNull indicator, "Expected an indicator to be created"
    done()
  ).catch(done)
)

test('.createOrUpdateIndicator when there is an existing indicator
  with the given name, it updates the indicator', (done) ->

  theIndicator = null
  theName = 'a name'
  importer = new XlsxIndicatorImporter()
  importer.indicatorProperties.name = theName

  helpers.createIndicatorModels([
    indicatorationConfig:
      source: "xlsx"
    name: theName
  ]).get(0).then( (indicator) ->
    theIndicator = indicator
    importer.createOrUpdateIndicator()
  ).then( ->
    findIndicators = Promise.promisify(Indicator.find, Indicator)

    Promise.all([
      findIndicators(
        name: theName
      ),
      findIndicators({})
    ])
  ).spread((spreadsheetIndicators, allIndicators) ->

    assert.strictEqual allIndicators.length, 1,
      "Expected no more indicators to be created"

    assert.strictEqual spreadsheetIndicators.length, 1,
      "Expected only one indicator to exist"

    assert.strictEqual(
      spreadsheetIndicators[0].name,
      theName,
      "Expected the found indicator to have the same name"
    )

    done()
  ).catch(done)
)
