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

test("Can POST section to database", (done)->
  section = new Backbone.Models.Section(title: "test report title", report_id: 5)
  section.save(null,
    success: (model, response, options) ->
      assert _.isEqual(model.attributes, section.attributes), "Returned different attributes"
      assert.equal options.xhr.status, 201
      done()
    error: ->
      throw 'Section saved failed'
  )
)
