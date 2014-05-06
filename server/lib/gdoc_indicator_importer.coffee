Promise = require 'bluebird'
Indicator = require('../models/indicator').model
GDocWrapper = require('./gdoc_wrapper')

extractRangesFromWorksheet = (worksheet) ->
  index = 2

  ranges = []
  while (range = worksheet[index.toString()])?
    ranges.push(
      threshold:  range['1'].value
      text:  range['2'].value
    )
    index = index + 1

  return ranges

module.exports =
  import: (key) ->

    spreadsheet = null
    definition = {}

    GDocWrapper.importByKey(key).then((spr)->
      spreadsheet = spr

      spreadsheet.getWorksheetData('Definition')
    ).then((worksheet) ->

      definition.name = worksheet['2']['1'].value
      definition.theme = worksheet['2']['2'].value
      definition.unit = worksheet['2']['3'].value

      spreadsheet.getWorksheetData('Ranges')
    ).then((worksheet) ->

      definition.indicatorationConfig =
        source: 'gdoc'
        spreadsheet_key: key
        range: extractRangesFromWorksheet(worksheet)

      indicator = Indicator.buildWithDefaults(definition)

      Promise.promisify(indicator.save, indicator)()
    )
