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

test('.getFieldType returns the type of a field from the indicator definition', ->
  indicator = Factory.indicator(
    indicatorDefinition:
      fields:[
        name: 'theDate'
        type: 'date'
      ]
  )

  assert.strictEqual indicator.getFieldType('theDate'), 'date'
)

test('.getFieldType on an indicator with no field definition returns "Unknown"', ->
  indicator = Factory.indicator()

  assert.strictEqual indicator.getFieldType('someField'), 'Unknown'
)

test('.getFieldType on an indicator with no fields in the field definitions
returns "Unknown"', ->
  indicator = Factory.indicator(
    indicatorDefinition: {}
  )

  assert.strictEqual indicator.getFieldType('someField'), 'Unknown'
)
