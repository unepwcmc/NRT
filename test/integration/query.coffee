assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
IndicatorDataController = require('../../controllers/indicator_data')
Indicator = require('../../models/indicator')

suite('Indicator data controller')

test(".query given a request with indicator ID,
  it calls new Indicator(:id)", ->
  req =
    params:
      id: 5

  res =
    send: sinon.stub

  getDefinitionStub = sinon.stub(Indicator::, 'getDefinition', ->{})

  IndicatorDataController.query(req, res)

  assert.strictEqual getDefinitionStub.callCount, 1,
    "Expected an indicator to be initialised"

  assert.isTrue res.send.calledWith(200), "Expected the request to be a 200"
)
