suite('Indicator Model')

test('when initialised with page attributes, it creates a page model with those attributes', ->
  indicator = Factory.indicator(page: {})

  assert.strictEqual indicator.get('page').constructor.name, 'Page'
)

test('when initialised with owner attributes, it creates an user model with
  those attributes', ->
  indicator = Factory.indicator(owner: {})

  assert.strictEqual indicator.get('owner').constructor.name, 'User'
)

test('.toJSON when model has owner attributes only includes the owner id', ->
  owner = Factory.user()
  indicator = Factory.indicator(owner: owner)

  json = indicator.toJSON()
  assert.strictEqual json.owner, owner.get(Backbone.Models.User::idAttribute)
)
