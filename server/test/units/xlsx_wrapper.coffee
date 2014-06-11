assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
Promise = require 'bluebird'

XlsxWrapper = require '../../lib/xlsx_wrapper'

suite('XlsxWrapper')

test("#importByPath fetches the spreadsheet from the given path
  and returns a XlsxWrapper with the data", (done) ->

  path = "path/to/file.xls"
  spreadsheetData = {some: 'data'}

  fetchStub = sinon.stub(XlsxWrapper, 'fetchSpreadsheet', (path)->
    unless path?
      return new Error("Expected fetchSpreadsheet to be called with path: #{
        path
      } but called with #{JSON.stringify(arguments)}")
    new Promise((res) -> res(spreadsheetData))
  )

  XlsxWrapper.importByPath(path).then((wrapper) ->
    try
      assert.deepEqual wrapper.spreadsheet, spreadsheetData,
        "Expected the returned object to have the spreadsheet data
        as an attribute"

      done()
    catch err
      done(err)

  ).catch((err)->
    console.log err
    done(err)
  ).finally(->
    fetchStub.restore()
  )
)

test('.getWorksheetData returns the data of the worksheet with the
  given name', (done) ->

  definitionData = {some: 'data'}

  xlsx = new XlsxWrapper({})

  sinon.stub(xlsx, 'getWorksheetByName', ->
    {data: definitionData}
  )

  xlsx.getWorksheetData('definition').then( (fetchedData) ->

    try
      assert.strictEqual fetchedData, definitionData,
        "Expected the right data to returned"

      done()
    catch err
      done(err)

  ).catch(done)
)

test('.getWorksheetData throws an appropriate error if no worksheet
 is found', (done) ->

  xlsx = new XlsxWrapper({})

  assert.throws((->
    xlsx.getWorksheetData('nonsense').catch(done)
  ), "Couldn't find worksheet named 'nonsense'")
  done()
)

test('.getWorksheetByName returns the worksheet with the given name', ->

  fakeSpreadsheet =
    worksheets: [
      { name: 'Data' },
      { name: 'Definition' }
    ]

  xlsx = new XlsxWrapper(fakeSpreadsheet)

  worksheet = xlsx.getWorksheetByName('Definition')

  assert.strictEqual worksheet, fakeSpreadsheet.worksheets[1],
    "Expected the correct worksheet to be returned"
)
