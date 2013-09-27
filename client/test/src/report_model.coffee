assert = chai.assert

suite('Backbone.Models.Report')

test('when initialised with page attributes, it creates a page model with those attributes', ->
  report = Factory.report(page: {})

  assert.strictEqual report.get('page').constructor.name, 'Page'
)
