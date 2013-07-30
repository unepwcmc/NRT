assert = require('chai').assert
utils = require '../../lib/utils'


data = [
  selectedValues:
    id: 30
    title: "Percent area with pesticide residue"
    description: null
    createdAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
    updatedAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
,
  selectedValues:
    id: 31
    title: "Forest area expansion"
    description: null
    createdAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
    updatedAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
,
  selectedValues:
    id: 32
    title: "Annual agriculture and forestry subsidies"
    description: null
    createdAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
    updatedAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
,
  selectedValues:
    id: 33
    title: "Limiting the loss of areas of natural vegetation"
    description: null
    createdAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
    updatedAt: "Sun Jul 28 2013 10:38:45 GMT+0100 (BST)"
]


suite('formatDate')

test('input and output arrays should be of the same length', ->
  assert.equal data.length, utils.formatDate(data).length
)

test('the data has been formatted as expected', ->
  formattedData = utils.formatDate(data, format="dddd")
  assert.equal formattedData[0].createdAt, "Sunday"
)