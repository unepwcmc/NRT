Promise = require 'bluebird'

module.exports = class GDocWrapper
  constructor: (@spreadsheet)->

  @fetchSpreadsheet: Promise.promisify(require "google-spreadsheets")

  @importByKey: (key) ->
    GDocWrapper.fetchSpreadsheet(key: key).then((spreadsheet) ->
      new GDocWrapper(spreadsheet)
    )

  getWorksheetData: ->
