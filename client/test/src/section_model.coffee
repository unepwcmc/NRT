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

test("Can POST section to database", (done)->
  section = new Backbone.Models.Section(title: "test report title", report_id: 5)
  section.save(null,
    success: (model, response, options) ->
      assert _.isEqual(model.attributes, section.attributes), "Returned different attributes"
      assert.equal response.status, 201
      done()
    error: ->
      throw 'Section saved failed'
  )
)
