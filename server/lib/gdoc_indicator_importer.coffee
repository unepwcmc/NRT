Promise = require 'bluebird'
Indicator = require('../models/indicator').model
GDocWrapper = require('./gdoc_wrapper')

buildIndicatorDefinitionFromSpreadsheet = ->

module.exports =
  import: (key) ->
    new Promise((resolve, reject) ->

      GDocWrapper.importByKey(key).then((spreadsheet)->

        spreadsheet.getWorksheetData('definition')
      ).then((def) ->

        definition = buildIndicatorDefinitionFromSpreadsheet(def)

        Promise.promisify(Indicator.create, Indicator)(definition)
      ).then(
        resolve, reject
      )
    )
