suite('Search results view')

test('when given a collection of users I should see their emails', ->
  userAttributes = [
    {name: "Steve Bennett"}
    {name: "Ted MacAllister"}
  ]

  users = new Backbone.Collections.UserCollection(userAttributes)

  view = new Backbone.Views.SearchResultsView(collection: users)

  Helpers.renderViewToTestContainer(view)

  for attributes in userAttributes
    assert.match $('#test-container').text(), new RegExp(attributes.name)

  view.close()
)

test("when click on a username, it triggers a 'select' event with the selection", ->
  userAttributes = [
    {_id: Factory.findNextFreeId('User'), name: "Steve Bennett"}
  ]

  users = new Backbone.Collections.UserCollection(userAttributes)

  view = new Backbone.Views.SearchResultsView(collection: users)

  Helpers.renderViewToTestContainer(view)

  userSelectedListener = sinon.spy((selection) ->
    assert.strictEqual selection.get('name'), userAttributes[0].name
  )

  view.on('select', userSelectedListener)

  $('#test-container').find('li').trigger('click')

  assert.ok(
    userSelectedListener.calledOnce,
    "Expected userSelectedListener to be called once but was called
      #{userSelectedListener.callCount} times"
  )

  view.close()
)
