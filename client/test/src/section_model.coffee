assert = chai.assert

suite('Section Model')

test("When initialised with visualisation attributes,
  it creates a Backbone.Models.Visualisation model in the visualisation attribute", ->
  visualisationAttributes = data: {some: 'data'}
  section = new Backbone.Models.Section(visualisation: visualisationAttributes)

  assert.equal section.get('visualisation').constructor.name, 'Visualisation'
  assert.equal section.get('visualisation').get('data'), visualisationAttributes.data
)

test("When initialised with narrative attributes,
  it creates a Backbone.Models.Narrative model in the narrative attribute", ->
  narrativeAttributes = content: "I'm narrative text"
  section = new Backbone.Models.Section(narrative: narrativeAttributes)

  assert.equal section.get('narrative').constructor.name, 'Narrative'
  assert.equal section.get('narrative').get('content'), narrativeAttributes.content
)
