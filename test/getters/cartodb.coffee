assert = require('chai').assert
sinon = require('sinon')
Q = require('q')
_ = require('underscore')

Indicator = require('../../models/indicator')
CartoDBGetter = require("../../getters/cartodb")

suite('CartoDB getter')

test("CartoDBGetter stores a reference to the given indicator", ->
  indicator = {some: "data"}

  getter = new CartoDBGetter(
    indicator
  )

  assert.strictEqual(getter.indicator, indicator)
)
