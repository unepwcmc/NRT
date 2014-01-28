assert = require('chai').assert
sinon = require('sinon')

DataConverter = require '../../lib/data_converter'

suite("DataConverter")

test("#convert('percentage', 'decimal', value) converts an integer percentage to a decimal", ->
  result = DataConverter.convert('percentage', 'decimal', '50')
  assert.equal(result, 0.5)
)

test("#convert('date', 'epoch', value) converts a JS date to an epoch", ->
  result = DataConverter.convert('date', 'epoch', '2013')
  assert.equal(result, 1356998400000)
)

test("#convert('nonsense', 'rubbish', value) throws an appropriate error", ->
  assert.throws((->
    DataConverter.convert('nonsense', 'rubbish', 123123)
  ), "DataConverter doesn't know how to convert 'nonsense' into 'rubbish'")
)

test("#convert throws an appropriate error when type is null", ->
  assert.throws((->
    DataConverter.convert('date', 'epoch', null)
  ), "DataConverter can't convert null or undefined values")
)
