assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'
Promise = require 'bluebird'

GDocWrapper = require '../../lib/gdoc_wrapper'

suite('GDocWrapper')

test("#importByKey fetches the spreadsheet for the given key
  and returns a GDocWrapper with the data", (done) ->

  key = 'woozle-wuzzle'
  spreadsheetData = {some: 'data'}

  fetchStub = sinon.stub(GDocWrapper, 'fetchSpreadsheet', (options)->
    unless options.key is key
      return new Error("Expected fetchSpreadsheet to be called with key: #{
        key
      } but called with #{JSON.stringify(options)}")
    new Promise((res) -> res(spreadsheetData))
  )

  GDocWrapper.importByKey(key).then((wrapper) ->
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

  gdoc = new GDocWrapper({})

  sinon.stub(gdoc, 'getWorksheetByName', ->
    title: 'Definition', cells: (range, cb) ->
      cb(null, cells: definitionData)
  )

  gdoc.getWorksheetData('definition').then((fetchedData) ->

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

  gdoc = new GDocWrapper({})

  assert.throws((->
    gdoc.getWorksheetData('nonsense').catch(done)
  ), "Couldn't find worksheet named 'nonsense'")
  done()
)

test('.getWorksheetByName returns the worksheet with the given name', ->

  fakeSpreadsheet =
    worksheets: [
      { id: 1, title: 'Data' },
      { id: 2, title: 'Definition' }
    ]

  gdoc = new GDocWrapper(fakeSpreadsheet)

  worksheet = gdoc.getWorksheetByName('Definition')

  assert.strictEqual worksheet, fakeSpreadsheet.worksheets[1],
    "Expected the correct worksheet to be returned"
)
