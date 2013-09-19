assert = chai.assert

suite('Backbone.Models.Report')

test("When initialised without a sections attributes, it creates a section collection", ->
  report = new Backbone.Models.Report()
  assert.equal report.get('sections').constructor.name, 'SectionCollection'
)

test("When initialised with an array of sections,
  creates a section collection containing those elements", ->
  sections = [new Backbone.Models.Section()]
  report = new Backbone.Models.Report(sections: sections)
  assert.equal report.get('sections').constructor.name, 'SectionCollection'
)

test('when initialised with sections attributes,
  it creates a section with a reference to the indicator parent', ->
  report = new Backbone.Models.Report(
    sections: [
      title: "I'm a child"
    ]
  )

  assert.strictEqual report.get('sections').constructor.name, 'SectionCollection'
  assert.strictEqual report.get('sections').at(0).get('title'), "I'm a child"
  assert.strictEqual report.get('sections').at(0).get('parent').cid, report.cid
  assert.strictEqual report.get('sections').at(0).get('parent').constructor.name, "Report"
)

test(".toJSON should include nested section objects as their JSON", ->
  sections = [new Backbone.Models.Section(
    indicator: new Backbone.Models.Indicator()
    title: "dat working"
  )]
  report = new Backbone.Models.Report(sections: sections)

  sectionsJSON = _.map sections, (section)->
    section.toJSON()
  assert.ok(
    _.isEqual(report.toJSON().sections, sectionsJSON),
    "Expected \n#{JSON.stringify(report.toJSON().sections)}\n
     to equal \n#{JSON.stringify(sectionsJSON)}"
  )
)
