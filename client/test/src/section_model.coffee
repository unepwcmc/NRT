assert = chai.assert

suite('Section Model')

test("Has many narratives", ->
  section = new Backbone.Models.Section()
  assert.equal 'NarrativeCollection', section.get('narratives').constructor.name
)

test("Has many visualisations", ->
  section = new Backbone.Models.Section()
  assert.equal 'VisualisationCollection', section.get('visualisations').constructor.name
)

test("When initialised with an array of visualisations, creates a visualisation collection", ->
  visualisations = [new Backbone.Models.Visualisation()]
  section = new Backbone.Models.Section(visualisations: visualisations)
  assert.equal section.get('visualisations').constructor.name, 'VisualisationCollection'
)

test("When initialised with an array of narratives, creates a narrative collection", ->
  narratives = [new Backbone.Models.Narrative()]
  section = new Backbone.Models.Section(narratives: narratives)
  assert.equal section.get('narratives').constructor.name, 'NarrativeCollection'
)
