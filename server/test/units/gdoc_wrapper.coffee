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

  ).catch(done)
  .finally(->
    fetchStub.restore()
  )
)
