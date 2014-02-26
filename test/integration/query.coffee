assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Q = require 'q'

IndicatorDataController = require('../../controllers/indicator_data')
Indicator = require('../../models/indicator')

suite('Indicator data controller')

test(".query given a request with indicator ID,
  it calls Indicator.find with that id and then calls .query on that indicator", (done)->
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

        assert.strictEqual dummyIndicator.query.callCount, 1,
          "Expected 'query' to be called on the indicator returned by Indicator.find"

        done()
      catch err
        done(err)
      finally
        indicatorFindStub.restore()

  dummyIndicator =
    query: sinon.spy(->
      Q.fcall(->)
    )

  indicatorFindStub = sinon.stub(Indicator, 'find', ->
    Q.fcall( ->
      dummyIndicator
    )
  )

  IndicatorDataController.query(req, res)
)
