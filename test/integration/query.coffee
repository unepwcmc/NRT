assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Q = require 'q'

IndicatorDataController = require('../../controllers/indicator_data')
Indicator = require('../../models/indicator')

suite('Indicator data controller')

test(".query given a request with indicator ID,
  it calls Indicator.find with that id", (done)->
  req =
    params:
      id: 5

  res =
    send: (response, body) ->
      try
        assert.strictEqual response, 200,
          "Expected the request to return a 200"

        assert.strictEqual indicatorFindStub.callCount, 1,
          "Expected an indicator to be fetched"
        assert.isTrue indicatorFindStub.calledWith(req.params.id),
          "Expected Indicator.find to be called with the given ID"
        done()
      catch err
        done(err)
      finally
        indicatorFindStub.restore()

  indicatorFindStub = sinon.stub(Indicator, 'find', ->
    Q.fcall(->)
  )

  IndicatorDataController.query(req, res)
)
