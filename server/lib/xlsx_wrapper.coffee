Promise = require 'bluebird'
nodeXlsx = require 'node-xlsx'
_ = require 'underscore'

module.exports = class XlsxWrapper
  constructor: (@spreadsheet) ->

  @fetchSpreadsheet: (path) ->
    Promise.resolve(nodeXlsx.parse(path))

  @importByPath: (path) ->
    XlsxWrapper.fetchSpreadsheet(path).then( (spreadsheet) ->
      new XlsxWrapper(spreadsheet)
    )

  getWorksheetByName: (name) ->
    _.findWhere(@spreadsheet.worksheets, {name: name})

  getWorksheetData: (worksheetName) ->
    worksheet = @getWorksheetByName(worksheetName)

    unless worksheet?
      throw new Error("Couldn't find worksheet named '#{worksheetName}'")

    Promise.resolve(worksheet.data)
