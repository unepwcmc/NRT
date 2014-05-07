_ = require('underscore')
Promise = require('bluebird')

module.exports = class GDoc
  constructor: (@indicator) ->

  fetch: ->
    new Promise( (resolve, reject) =>
      @queryGoogleSpreadsheet(
        key: @indicator.indicatorationConfig.spreadsheetKey
      ).then( (spreadsheet) =>

        spreadsheet.worksheets[0].cells({}, (err, cells) =>
          headers = cells.cells['1']
          indicatorData = _.filter(cells.cells, (row) =>
            row['2'].value is @indicator.short_name
          )

          resolve({
            headers: headers
            data: indicatorData
          })
        )

      ).catch( (err) ->
        reject(err)
      )
    )

  queryGoogleSpreadsheet: Promise.promisify(require("google-spreadsheets"))
