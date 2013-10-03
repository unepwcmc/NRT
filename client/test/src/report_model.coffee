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

test('when initialised with owner attributes, it creates an user model with
  those attributes', ->
  report = Factory.report(owner: {})

  assert.strictEqual report.get('owner').constructor.name, 'User'
)

test('.toJSON when model has owner attributes only includes the owner id', ->
  owner = Factory.user()
  report = Factory.report(owner: owner)

  json = report.toJSON()
  assert.strictEqual json.owner, owner.get(Backbone.Models.User::idAttribute)
)
