assert = chai.assert

suite('Section Model')

test("When intialising a section with a nested visualisation,
  visualisation.toJSON should return section: as section._id", ->
  indicator = Factory.indicator()
  visualisation = new Backbone.Models.Visualisation(indicator: indicator)
  sectionAttributes =
    indicator: indicator
    visualisation: visualisation

  section = Factory.section(sectionAttributes)

  assert.strictEqual section.get('visualisation').toJSON().section, sectionAttributes._id
)

test("When calling .toJSON on a section with an indicator model attribute,
  the indicator model should be deserialized to the indicator _id", ->
  indicatorAttributes = _id: 5, name: 'hat'

  section = new Backbone.Models.Section(indicator: indicatorAttributes)
  assert.equal section.toJSON().indicator, indicatorAttributes._id
)

test('.toJSON should not include a visualisation attribute
  (as visualisations save themselves with the section._id)', ->
  section = new Backbone.Models.Section(
    visualisation:
      _id: 23423
      indicator: {}
  )
  assert.isUndefined section.toJSON().visualisation
)

test('.toJSON should not include a narrative attribute
  (as narratives save themselves with the section._id)', ->
  section = new Backbone.Models.Section(
    narrative:
      _id: 23423
      content: 'bees'
  )
  assert.isUndefined section.toJSON().narrative
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
  section = new Backbone.Models.Section(indicator: {name: 'an indicator'})

  assert.ok section.hasTitleOrIndicator()
)

test("When initialised with visualisation attributes,
  it creates a Backbone.Models.Visualisation model in the visualisation attribute", ->
  visualisationAttributes = data: {some: 'data'}, indicator: Factory.indicator()
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
  indicatorAttributes = name: "I'm an indicator"
  section = new Backbone.Models.Section()
  section.set('indicator', indicatorAttributes)

  assert.equal section.get('indicator').constructor.name, 'Indicator'
  assert.equal section.get('indicator').get('name'), indicatorAttributes.name
)

test(".save should actually call save on the parent page model", (done)->
  page = new Backbone.Models.Page(
    sections: [{
      title: 'dat title'
    }]
  )
  section = page.get('sections').at(0)

  pageSaveSpy = sinon.stub(page, 'save', (attributes, options)->
    options.success(page, 200, options)
  )

  section.save(null,
    success: (model, response, options) ->
      assert.ok pageSaveSpy.calledOnce, "page save not called"
      done()
    error: ->
      throw 'Section saved failed'
  )
)

test('.getPage should get the parent page', ->
  page = Factory.page(sections: [{title: 'A section'}])
  section = page.get('sections').at(0)

  assert.strictEqual(
    section.getPage().cid,
    page.cid,
    "Expected the Section page to be the same as page"
  )
)

test('EditModeMixin is mixed in', ->
  section = new Backbone.Models.Section()

  assert.isDefined section.isEditable, 'Expected Section to have method .isEditable'
)
