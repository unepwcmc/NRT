Promise = require 'bluebird'
_ = require 'underscore'

XlsxWrapper = require('../lib/xlsx_wrapper.coffee')
Indicator = require('../models/indicator').model
Theme = require('../models/theme').model

DEFAULT_INDICATOR_DEFINITION =
  "period": "yearly",
  "xAxis": "year",
  "yAxis": "value",
  "geometryField": "geometry",
  "fields": [
    {
      "source": {
        "name": "periodStart",
        "type": "integer"
      },
      "name": "year",
      "type": "integer"
    }, {
      "source": {
        "name": "value",
        "type": "text"
      },
      "name": "value",
      "type": "decimal"
    }, {
      "source": {
        "name": "text",
        "type": "text"
      },
      "name": "text",
      "type": "text"
    }
  ]

mergeAttributesWithDefaults = (attributes) ->
  attributes.indicatorDefinition = _.extend(
    DEFAULT_INDICATOR_DEFINITION, attributes.indicatorDefinition
  )
  return attributes

extractRangesFromWorksheet = (worksheet) ->
  index = 1

  ranges = []
  while (range = worksheet[index])?
    ranges.push(
      threshold: parseFloat(range[0].value, 10)
      text: range[1].value
    )
    index = index + 1

  return ranges

module.exports = class XlsxIndicatorImporter
  constructor: ->
    @indicatorProperties = {
      indicatorationConfig:
        source: 'xlsx'
    }

  @import: (path) ->
    XlsxWrapper.importByPath(
      path
    ).then( (spreadsheet) ->
      Promise.all([
        spreadsheet.getWorksheetData('Definition'),
        spreadsheet.getWorksheetData('Ranges')
      ])
    ).spread((definitionWorksheet, rangesWorksheet) ->
      indicatorImporter = new XlsxIndicatorImporter()
      indicatorImporter.setDefinitionFromWorksheet(
        definitionWorksheet
      ).then( ->
        indicatorImporter.setRangesFromWorksheet(rangesWorksheet)
        indicatorImporter.createOrUpdateIndicator()
      )
    )

  setDefinitionFromWorksheet: (worksheet) ->
    themeTitle = worksheet[1][1].value

    Theme.findOrCreateByTitle(themeTitle).then( (theme) =>
      _.extend(@indicatorProperties, {
        shortName: worksheet[1][0].value
        name: worksheet[1][0].value
        theme: theme._id
        indicatorDefinition:
          unit: worksheet[1][2].value
          shortUnit: worksheet[1][2].value
      })
    )

  setRangesFromWorksheet: (worksheet) ->
    @indicatorProperties.indicatorationConfig.range = extractRangesFromWorksheet(
      worksheet
    )

  createOrUpdateIndicator: ->
    existingIndicator = Promise.promisify(Indicator.findOne, Indicator)(
      'indicatorationConfig.spreadsheetKey': @indicatorProperties.indicatorationConfig.spreadsheetKey
    ).then( (indicator) =>
      @indicatorProperties = mergeAttributesWithDefaults(@indicatorProperties)
      if indicator?
        Promise.promisify(indicator.update, indicator)(@indicatorProperties)
      else
        Promise.promisify(Indicator.create, Indicator)(@indicatorProperties)
    )
