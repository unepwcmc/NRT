Promise = require 'bluebird'
_ = require 'underscore'

GDocWrapper = require('./gdoc_wrapper')
Indicator = require('../models/indicator').model
Theme = require('../models/theme').model

extractRangesFromWorksheet = (worksheet) ->
  index = 2

  ranges = []
  while (range = worksheet[index.toString()])?
    ranges.push(
      minValue: parseFloat(range['1'].value, 10)
      message: range['2'].value
    )
    index = index + 1

  return ranges

module.exports = class GDocIndicatorImporter
  constructor: (key) ->
    @indicatorProperties = {
      indicatorationConfig:
        source: 'gdoc'
        spreadsheet_key: key
    }

  @import: (key) ->
    GDocWrapper.importByKey(key).then((spreadsheet) ->
      Promise.all([
        spreadsheet.getWorksheetData('Definition'),
        spreadsheet.getWorksheetData('Ranges')
      ])
    ).spread((definitionWorksheet, rangesWorksheet) ->
      indicatorImporter = new GDocIndicatorImporter(key)
      indicatorImporter.setDefinitionFromWorksheet(
        definitionWorksheet
      ).then( ->
        indicatorImporter.setRangesFromWorksheet(rangesWorksheet)
        indicatorImporter.createIndicator()
      )
    )

  setDefinitionFromWorksheet: (worksheet) ->
    themeTitle = worksheet['2']['2'].value

    return Theme.findOrCreateByTitle(themeTitle).then((theme) =>
      _.extend(@indicatorProperties, {
        short_name: worksheet['2']['1'].value
        title: worksheet['2']['1'].value
        theme: theme._id
        indicatorDefinition:
          unit: worksheet['2']['3'].value
          short_unit: worksheet['2']['3'].value
      })
    )

  setRangesFromWorksheet: (worksheet) ->
    @indicatorProperties.indicatorationConfig.range = extractRangesFromWorksheet(
      worksheet
    )

  createIndicator: ->
    indicator = Indicator.buildWithDefaults(@indicatorProperties)
    Promise.promisify(indicator.save, indicator)()

