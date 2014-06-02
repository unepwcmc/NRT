Q = require('q')
assert = require('chai').assert
request = require('request')
sinon = require('sinon')
_ = require('underscore')

Converter = require('../../lib/converter')

suite('Converter')

test('.convertData, when given valid epoch to integer field translation,
  it converts the field to the correct name and type', (done) ->

  indicatorFields = [
      source:
        name: "date"
        type: "epoch"
      name: "year"
      type: "integer"
    ,
      source:
        name: "value"
        type: "integer"
      name: "value"
      type: "integer"
  ]

  untranslatedData = [
      date: "599616034000"
      value: 23
    ,
      date: "1388534434000"
      value: 25
  ]

  expectedData = [
      year: 1989
      value: 23
    ,
      year: 2014
      value: 25
  ]

  convertedDataPromise = Converter.convertData(indicatorFields, untranslatedData)

  convertedDataPromise.then( (convertedData) ->
    assert.deepEqual expectedData, convertedData,
      "Expected converted data:\n
      #{JSON.stringify(convertedData)}\n
        to look like expected indicator data:\n
      #{JSON.stringify(expectedData)}"
    done()
  ).fail(done)
)


test('.translateRow includes fields with definitions and skips those without', ->

  row = {
    periodStart: 12343242300000
    fresh: true
  }

  fieldFinderStub = {
    bySourceName: (sourceName) ->
      return {
        source:
          name: 'periodStart'
          type: 'integer'
        name: 'year'
        type: 'integer'
      }
  }

  translatedRow = Converter.translateRow(row, fieldFinderStub)

  assert.property translatedRow, 'year',
    "Expected periodStart property to be included in translatedRow"
  assert.notProperty translatedRow, 'fresh',
    "Expected periodStart property to not be included in translatedRow"
)

test('.convertSourceValueToInternalValue when given two values of the same
  type it returns same value', ->

  result = Converter.convertSourceValueToInternalValue('integer', 'integer', 5)
  assert.strictEqual result, 5,
    "Expected conversion not to modify source value"
)

test(".convertSourceValueToInternalValue when given a type conversion which
  doesn't exist, it throws appropriate error", ->

  assert.throws (->
    Converter.convertSourceValueToInternalValue('apples', 'oranges', 5)
  ), "Don't know how to convert 'apples' to 'oranges'"

)

test(".convertSourceValueToInternalValue when given a decimalPercentage to
  integer conversion, it multiplies by 100", ->

  result = Converter.convertSourceValueToInternalValue('decimalPercentage', 'integer', 0.504)
  assert.strictEqual result, 50.4,
    "Expected value to be mutliplied by 100"
)

test(".convertSourceValueToInternalValue when given a text to
  decimal conversion parses a float", ->

  result = Converter.convertSourceValueToInternalValue('text', 'decimal', "0.1")
  assert.strictEqual result, 0.1,
    "Expected the correct value to be parsed"
)


test(".convertSourceValueToInternalValue when given an epoch to
  date conversion, it converts the value correctly", ->

  result = Converter.convertSourceValueToInternalValue('epoch', 'date', 1325376000000)

  assert.ok typeof result.getMonth is 'function',
    "Expected the result to be a date"
  assert.strictEqual result.getMonth(), 0,
    "Expected the date to be in October"
  assert.strictEqual result.getFullYear(), 2012,
    "Expected the date to be in 2013"
)

test(".FieldFinder is initialized with indicator fields", ->

  fields = [{a: 1}]
  fieldFinder = new Converter.FieldFinder(fields)

  assert.deepEqual fieldFinder.fields, fields,
    "Expected fieldFinder's fields to be initialized with passed value"
)

test(".FieldFinder populates indicatorFields cache with indicators by source name", ->

  field =
    source:
      name: "year"
      type: "integer"
    name: "year"
    type: "integer"

  sourceNameLookup = "year"

  fieldFinder = new Converter.FieldFinder([field])
  fieldFinder.bySourceName(sourceNameLookup)

  assert.deepEqual fieldFinder.fieldDefinitions[sourceNameLookup], field,
    "Expected fieldFinder's cache to contain correct field"
)