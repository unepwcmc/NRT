_ = require('underscore')
Q = require('q')

module.exports = class GDoc
  constructor: (indicator) ->
    deferred = Q.defer()

    @queryGoogleSpreadsheet(
      key: indicator.spreadsheet_key
    ).then( (spreadsheet) ->

      spreadsheet.worksheets[0].cells({}, (err, cells) ->
        row = _.filter(cells.cells, (row) ->
          row['2'].value is indicator.name
        )[0]

        deferred.resolve row
      )

    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  queryGoogleSpreadsheet: Q.denodeify(require("google-spreadsheets"))
