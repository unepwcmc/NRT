Promise = require 'bluebird'
fetchSpreadsheet = Promise.promisify(require "google-spreadsheets")

module.exports = class GDocWrapper

  @importByKey: (key) ->
    fetchSpreadsheet(key: key).then((spreadsheet) ->
    )

  getWorksheetData: ->
