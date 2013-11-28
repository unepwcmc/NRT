assert = require('chai').assert
_ = require('underscore')
sinon = require('sinon')
Esri = require '../indicatorators/esri'

suite('ESRI indicatorator')

test('addIndicatorTextToData adds the correct indicator text', ->
  calculateIndicatorTextStub = sinon.stub(Esri, '_calculateIndicatorText', () ->
    return 'Great'
  )

  rows = [
    {"OBJECTID":1,"periodStar":1364774400000,"value":6,"station":"Liwa Oasis","text":"YES"}
  ]
  indicatorDefinition =
    valueField: 'value'

  results = Esri.addIndicatorTextToData(rows, 'CODE', indicatorDefinition)

  assert.lengthOf results, 1, "Expected no rows to be removed"

  result = results[0]
  assert.strictEqual result.text, 'Great', "Expected the text value to be set to 'great'"

  calculateIndicatorTextStub.restore()
)

test('#getFeatureAttributesFromData maps merged attributes and geometry into a single object', ->
  data =
    features: [{
      geometry: {x: 5, y: 3}
      attributes:
        name: 'boat'
    }]

  mappedAttributesFromData = Esri.getFeatureAttributesFromData(data)

  assert.lengthOf mappedAttributesFromData, 1,
    "Expected the number of rows not to be changed"

  row = mappedAttributesFromData[0]
  assert.property row, 'geometry',
    "Expected the geometry attribute to be at the top level"

  assert.property row, 'name',
    "Expected the name attribute to be at the top level"
)
