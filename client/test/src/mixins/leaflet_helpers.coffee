suite('LeafletHelpers')

test('generatePopupText builds text with the only fields from the indicator definition', ->
  data =
    value: 10
    text: 'Excellent'
    rubbish: 'No help'
  indicatorDefinition =
    fields: [
      {name: 'value'}, {name: 'text'}
    ]

  text = Libs.LeafletHelpers.generatePopupText(data, indicatorDefinition)

  assert.match text, new RegExp(".*#{data.text}.*"),
    "Expected value 'text' from the field definition to be included"
  assert.match text, new RegExp(".*#{data.value}.*"),
    "Expected value 'value' from the field definition to be included"
  assert.notMatch text, new RegExp(".*#{data.rubbish}.*"),
    "Expected value of 'rubbish' not be included, as it is not in the field definitions"
)

test('generatePopupText does not print fields which are objects', ->
  data =
    geometry: {hat: 'boat'}

  indicatorDefinition =
    fields: [
      {name: 'geometry'}
    ]

  text = Libs.LeafletHelpers.generatePopupText(data, indicatorDefinition)

  assert.notMatch text, new RegExp(".*geometry.*"),
    "Expected the geometry field not to be included, as it is an object"
  assert.notMatch text, new RegExp(".*Object.*"),
    "Expected object not to be included"
)
