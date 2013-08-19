assert = chai.assert

suite('Section Model')

test("When intialising a section with nested visualisations,
  visualisation.toJSON should return section: as section._id", ->
  sectionAttributes = {
    _id: 5
    indicator: {
      _id: 15
    }
    visualisation: {
      _id: 25
      indicator: {
        _id: 15
      }
    }
  }
  section = new Backbone.Models.Section(sectionAttributes)

  assert.strictEqual section.get('visualisation').toJSON().section, sectionAttributes._id
)

test("When calling .toJSON on a section with an indicator model attribute,
  the indicator model should be deserialized to the indicator _id", ->
  indicatorAttributes = _id: 5, title: 'hat'

  section = new Backbone.Models.Section(indicator: indicatorAttributes)
  assert.equal section.toJSON().indicator, indicatorAttributes._id
)

test('.toJSON should not include Visualisation attribute
  (as visualisations save themselves with the section._id)', ->
  section = new Backbone.Models.Section(
    visualisation:
      _id: 23423
      indicator: {}
  )
  assert.isUndefined section.toJSON().visualisation
)

test(".hasTitleOrIndicator returns false if there is no title and no indicator assigned", ->
  section = new Backbone.Models.Section()

  assert.notOk section.hasTitleOrIndicator()
)

test(".hasTitleOrIndicator returns true if there is a title present", ->
  section = new Backbone.Models.Section(title: 'title')

  assert.ok section.hasTitleOrIndicator()
)

test(".hasTitleOrIndicator returns true if there is an indicator present", ->
  section = new Backbone.Models.Section(indicator: {title: 'an indicator'})

  assert.ok section.hasTitleOrIndicator()
)

test("When initialised with visualisation attributes,
  it creates a Backbone.Models.Visualisation model in the visualisation attribute", ->
  visualisationAttributes = data: {some: 'data'}, indicator: Helpers.factoryIndicator()
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

test("When setting 'indicator' with indicator attributes,
  it creates a Backbone.Models.Indicator model in the indicator attribute", ->
  indicatorAttributes = title: "I'm an indicator"
  section = new Backbone.Models.Section()
  section.set('indicator', indicatorAttributes)

  assert.equal section.get('indicator').constructor.name, 'Indicator'
  assert.equal section.get('indicator').get('title'), indicatorAttributes.title
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
