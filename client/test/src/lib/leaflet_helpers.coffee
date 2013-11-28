suite('LeafletHelpers')

test('generatePopupText builds a table with the headline values', ->
  headline =
    value: 10
    text: 'Excellent'
    unit: 'Boats'

  getHeadlineStub = sinon.stub(Nrt.Presenters.SubIndicatorDataPresenter::,
    'getHeadlineFromData', ->
      headline
  )

  indicatorDefinition =
    subIndicatorField: 'station'

  data =
    station: 'Train'

  text = Libs.LeafletHelpers.generatePopupText(data, indicatorDefinition)

  try
    assert.match text, new RegExp(".*#{headline.text}.*"),
      "Expected the headline text to be included"
    assert.match text, new RegExp(".*#{headline.value}.*"),
      "Expected the headline value to included"
    assert.match text, new RegExp(".*#{data.station}.*"),
      "Expected the subIndicatorField value to be included"
  catch e
    throw e
  finally
    getHeadlineStub.restore()
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
