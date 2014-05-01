Promise = require 'bluebird'
Indicator = require('../models/indicator').model

buildIndicatorDefinitionFromSpreadsheet = ->

module.exports =
  import: (key) ->
    new Promise((resolve, reject) ->
      module.exports.fetch(key).then((spreadsheet)->
        console.log spreadsheet
        spreadsheet.worksheets[1].cells({}, (err, cells) ->
          console.log "Checkout dem cells:"
          console.log cells.cells
        )
        definition = buildIndicatorDefinitionFromSpreadsheet(spreadsheet)

        Promise.promisify(Indicator.create, Indicator)(definition)
      ).then(
        resolve, reject
      )
    )

  fetch: (key) ->
    Promise.promisify(require "google-spreadsheets")(key: key)
