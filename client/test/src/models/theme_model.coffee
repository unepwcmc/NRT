suite('Theme Model')

test('when initialised with page attributes, it creates a page model with those attributes', ->
  theme = Factory.theme(page: {})

  assert.strictEqual theme.get('page').constructor.name, 'Page'
)

test('when initialised with owner attributes, it creates an user model with
  those attributes', ->
  theme = Factory.theme(owner: {})

  assert.strictEqual theme.get('owner').constructor.name, 'User'
)

test('.toJSON when model has owner attributes only includes the owner id', ->
  owner = Factory.user()
  theme = Factory.theme(owner: owner)

  json = theme.toJSON()
  assert.strictEqual json.owner, owner.get(Backbone.Models.User::idAttribute)
)
