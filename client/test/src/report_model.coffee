assert = chai.assert

suite('Backbone.Models.Report')

test('when initialised with page attributes, it creates a page model with those attributes', ->
  report = Factory.report(page: {})

  assert.strictEqual report.get('page').constructor.name, 'Page'
)

test("Page model's parent_id is updated when the Report ID changes", ->
  report = Factory.report(page: {})

  reportId = Factory.findNextFreeId('Report')
  report.set(Backbone.Models.Report::idAttribute, reportId)

  assert.strictEqual report.get('page').get('parent_id'), reportId
  assert.strictEqual report.get('page').get('parent_type'), "Report"
)
