assert = chai.assert

suite('Section Model')

test("Has many visualisations", ->
  section = new Backbone.Models.Section()
  assert.equal 'VisualisationCollection', section.get('visualisations').constructor.name
)

test("When initialised with an array of visualisations, creates a visualisation collection", ->
  visualisations = [new Backbone.Models.Visualisation()]
  section = new Backbone.Models.Section(visualisations: visualisations)
  assert.equal section.get('visualisations').constructor.name, 'VisualisationCollection'
)

test("When initialised with narrative attributes,
  it creates a Backbone.Models.Narrative model in the narrative attribute", ->
  narrativeAttributes = text: "I'm narrative text"
  section = new Backbone.Models.Section(narrative: narrativeAttributes)

  assert.equal section.get('narrative').constructor.name, 'Narrative'
  assert.equal section.get('narrative').get('text'), narrativeAttributes.text
)
