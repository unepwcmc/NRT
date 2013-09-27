suite('Theme Model')

test('when initialised with page attributes, it creates a page model with those attributes', ->
  theme = Factory.theme(page: {})

  assert.strictEqual theme.get('page').constructor.name, 'Page'
)
