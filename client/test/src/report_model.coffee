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
