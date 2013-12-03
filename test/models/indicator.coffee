assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Indicator = require('../../models/indicator')
fs = require 'fs'

suite('Indicator data controller')

test(".find reads the definition from definitions/indicators.json", (done)->
  readFileStub = sinon.stub(fs, 'readFile', (filename, callback) ->
    callback()
  )

  Indicator.find(5).then((indicator) ->
    try
      assert.isTrue readFileStub.calledWith('../definitions/indicators.json'),
        "Expected find to read the definitions file"

      done()
    catch err
      done(err)
    finally
      readFileStub.restore()
  )
)
