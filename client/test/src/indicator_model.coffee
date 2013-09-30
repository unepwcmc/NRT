suite('Indicator Model')

test('when initialised with page attributes, it creates a page model with those attributes', ->
  indicator = Factory.indicator(page: {})

  assert.strictEqual indicator.get('page').constructor.name, 'Page'
)
