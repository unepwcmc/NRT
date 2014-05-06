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

buildIndicatorPropertiesFromWorksheet = (worksheet) ->
  return {
    short_name: worksheet['2']['1'].value
    title: worksheet['2']['1'].value
    indicatorDefinition:
      unit: worksheet['2']['3'].value
      short_unit: worksheet['2']['3'].value
  }

module.exports =
  import: (key) ->

    spreadsheet = null
    themeTitle = null
    indicatorProperties = {indicatorDefinition: {}}

    GDocWrapper.importByKey(key).then((spr)->
      spreadsheet = spr

      spreadsheet.getWorksheetData('Definition')
    ).then((worksheet) ->
      themeTitle = worksheet['2']['2'].value

      indicatorProperties = buildIndicatorPropertiesFromWorksheet(worksheet)

      spreadsheet.getWorksheetData('Ranges')
    ).then((worksheet) ->

      indicatorProperties.indicatorationConfig =
        source: 'gdoc'
        spreadsheet_key: key
        range: extractRangesFromWorksheet(worksheet)

      indicator = Indicator.buildWithDefaults(indicatorProperties)

      indicator.setThemeByTitle(themeTitle)
        .then(->
          Promise.promisify(indicator.save, indicator)()
        )
    )
