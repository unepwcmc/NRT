Q = require('q')

module.exports = class GDoc
  constructor: (indicator) ->
    deferred = Q.defer()

    @queryGoogleSpreadsheet(
      key: indicator.spreadsheet_key
    ).then( (spreadsheet) ->

      spreadsheet.worksheets[0].cells({}, (err, cells) ->
        deferred.resolve cells.cells
      )

    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  queryGoogleSpreadsheet: Q.denodeify(require("google-spreadsheets"))
