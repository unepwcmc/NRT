_ = require('underscore')
Q = require('q')

module.exports = class GDoc
  constructor: (indicator) ->
    @indicator = indicator

  fetch: ->
    deferred = Q.defer()

    @queryGoogleSpreadsheet(
      key: @indicator.spreadsheet_key
    ).then( (spreadsheet) =>

      spreadsheet.worksheets[0].cells({}, (err, cells) =>
        headers = cells.cells['1']
        indicatorData = _.filter(cells.cells, (row) =>
          row['2'].value is @indicator.name
        )

        deferred.resolve {
          headers: headers
          data: indicatorData
        }
      )

    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  queryGoogleSpreadsheet: Q.denodeify(require("google-spreadsheets"))
