assert = require('chai').assert

Sorter = require('../../lib/sorter')

suite('Sorter')

test('.sortData sorts data based on sorting property', (done) ->
  sortingProperty =
    field: "year"
    order: "asc"

  data = [
    year: 2013
    value: 1
  ,
    year: 2011
    value: 2
  ,
    year: 2014
    value: 1
  ]

  expectedData = [
    year: 2011
    value: 2
  ,
    year: 2013
    value: 1
  ,
    year: 2014
    value: 1
  ]

  Sorter.sortData(
    sortingProperty, data
  ).then( (sortedData) ->
    assert.deepEqual sortedData, expectedData,
      "Expected data to be sorted"
    done()
  ).fail(done)
)

test('.sortData throws error if sort ordering is not recognized', ->
  sortingProperty =
    field: "year"
    order: "nope"

  assert.throws((->
    Sorter.sortData(sortingProperty, [])
  ), "No known sorting order 'nope'")
)