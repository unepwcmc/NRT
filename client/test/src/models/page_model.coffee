suite('Page Model')

test('.url() for a page with an ID returns /pages/id', ->
  page = Factory.page()
  assert.strictEqual page.url(), "/api/pages/#{page.id}"
)

test('when initialised with no section attribute, it creates and empty section collection', ->
  page = new Backbone.Models.Page(section: null)

  assert.strictEqual page.get('sections').constructor.name, 'SectionCollection'
)

test('when initialised with sections attributes,
  it creates a section with a reference to the parent page', ->
  page = new Backbone.Models.Page(
    sections: [
      title: "I'm a child"
    ]
  )

  assert.strictEqual page.get('sections').constructor.name, 'SectionCollection'
  assert.strictEqual page.get('sections').at(0).get('title'), "I'm a child"
  assert.strictEqual page.get('sections').at(0).get('page').cid, page.cid
  assert.strictEqual page.get('sections').at(0).get('page').constructor.name, "Page"
)

test('when adding a section to an page,
  it correctly sets the page attribute', ->
  page = new Backbone.Models.Page()
  page.get('sections').add({})

  assert.strictEqual page.get('sections').at(0).get('page').cid, page.cid
)

test(".toJSON should include nested section objects as their JSON", ->
  sections = [new Backbone.Models.Section(
    page: new Backbone.Models.Page()
    title: "dat working"
  )]
  page = new Backbone.Models.Page(sections: sections)

  sectionsJSON = _.map sections, (section)->
    section.toJSON()
  assert.ok(
    _.isEqual(page.toJSON().sections, sectionsJSON),
    "Expected \n#{JSON.stringify(page.toJSON().sections)}\n
     to equal \n#{JSON.stringify(sectionsJSON)}"
  )
)
