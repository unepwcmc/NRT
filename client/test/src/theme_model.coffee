suite('Theme Model')

test('when initialised with no section attribute, it creates an empty section collection', ->
  theme = new Backbone.Models.Theme(section: null)

  assert.strictEqual theme.get('sections').constructor.name, 'SectionCollection'
)

test('when initialised with sections attributes,
  it creates a section with a reference to the theme parent', ->
  theme = new Backbone.Models.Theme(
    sections: [
      title: "I'm a child"
    ]
  )

  assert.strictEqual theme.get('sections').constructor.name, 'SectionCollection'
  assert.strictEqual theme.get('sections').at(0).get('title'), "I'm a child"
  assert.strictEqual theme.get('sections').at(0).get('parent').cid, theme.cid
  assert.strictEqual theme.get('sections').at(0).get('parent').constructor.name, "Theme"
)

test('when adding a section to an theme,
  it correctly sets the parent attribute', ->
  theme = new Backbone.Models.Theme()
  theme.get('sections').add({})

  assert.strictEqual theme.get('sections').at(0).get('parent').cid, theme.cid
)

test(".toJSON should include nested section objects as their JSON", ->
  sections = [new Backbone.Models.Section(
    theme: new Backbone.Models.Theme()
    title: "dat working"
  )]
  theme = new Backbone.Models.Theme(sections: sections)

  sectionsJSON = _.map sections, (section)->
    section.toJSON()
  assert.ok(
    _.isEqual(theme.toJSON().sections, sectionsJSON),
    "Expected \n#{JSON.stringify(theme.toJSON().sections)}\n
     to equal \n#{JSON.stringify(sectionsJSON)}"
  )
)
