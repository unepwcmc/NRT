suite('Indicator Model')

test('when initialised with no section attribute, it creates and empty section collection', ->
  indicator = new Backbone.Models.Indicator(section: null)

  assert.strictEqual indicator.get('sections').constructor.name, 'SectionCollection'
)

test('when initialised with sections attributes,
  it creates a section with a reference to the indicator parent', ->
  indicator = new Backbone.Models.Indicator(
    sections: [
      title: "I'm a child"
    ]
  )

  assert.strictEqual indicator.get('sections').constructor.name, 'SectionCollection'
  assert.strictEqual indicator.get('sections').at(0).get('title'), "I'm a child"
  assert.strictEqual indicator.get('sections').at(0).get('parent').cid, indicator.cid
  assert.strictEqual indicator.get('sections').at(0).get('parent').constructor.name, "Indicator"
)

test('when adding a section to an indicator,
  it correctly sets the parent attribute', ->
  indicator = new Backbone.Models.Indicator()
  indicator.get('sections').add({})

  assert.strictEqual indicator.get('sections').at(0).get('parent').cid, indicator.cid
)

test(".toJSON should include nested section objects as their JSON", ->
  sections = [new Backbone.Models.Section(
    indicator: new Backbone.Models.Indicator()
    title: "dat working"
  )]
  indicator = new Backbone.Models.Indicator(sections: sections)

  sectionsJSON = _.map sections, (section)->
    section.toJSON()
  assert.ok(
    _.isEqual(indicator.toJSON().sections, sectionsJSON),
    "Expected \n#{JSON.stringify(indicator.toJSON().sections)}\n
     to equal \n#{JSON.stringify(sectionsJSON)}"
  )
)
