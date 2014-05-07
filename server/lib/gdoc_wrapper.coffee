Promise = require 'bluebird'
_ = require 'underscore'

module.exports = class GDocWrapper
  constructor: (@spreadsheet)->

  @fetchSpreadsheet: Promise.promisify(require "google-spreadsheets")

  @importByKey: (key) ->
    GDocWrapper.fetchSpreadsheet(key: key).then((spreadsheet) ->
      new GDocWrapper(spreadsheet)
    )

  getWorksheetByName: (name)->
    _.findWhere(@spreadsheet.worksheets, {title: name})

  getWorksheetData: (worksheetName) ->
    worksheet = @getWorksheetByName(worksheetName)

    unless worksheet?
      throw new Error("Couldn't find worksheet named '#{worksheetName}'")

    Promise.promisify(worksheet.cells, worksheet)({}).then((result)->
      result.cells
    )
