suite('Choose User View')

test('.setSelectedUser sets the selected user attribute and hides the results
  view', ->
  view = new Backbone.Views.ChooseUserView()

  Helpers.renderViewToTestContainer(view)

  user = Factory.user()
  view.setSelectedUser(user)

  assert.property view, 'selectedUser'
  assert.strictEqual view.selectedUser.cid, user.cid

  searchResultsView = view.subViews[0]
  assert.notOk(
    searchResultsView.$el.is(':visible'),
    "Expected the search results to be hidden"
  )

  view.close()
)

test(".setSelectedUser sets the input text to the user's name", ->
  view = new Backbone.Views.ChooseUserView()

  Helpers.renderViewToTestContainer(view)

  user = Factory.user(name: 'Nard Man')
  view.setSelectedUser(user)

  assert.strictEqual view.$el.find('input').val(), user.get('name')

  view.close()
)

test('.chooseUser when there is a selected user it triggers userSelected event
  with that user and closes the view', ->
  view = new Backbone.Views.ChooseUserView()

  user = Factory.user()
  view.setSelectedUser(user)

  userChosenListener = sinon.spy( (chosenUser) ->
    assert.strictEqual user.cid, chosenUser.cid
  )
  viewCloseSpy = sinon.spy(view, 'close')

  view.on('userSelected', userChosenListener)
  view.chooseUser()

  assert.ok(
    userChosenListener.calledOnce,
    "Expected userChosenListener to be called once but was called
      #{userChosenListener.callCount} times"
  )

  assert.ok(
    viewCloseSpy.calledOnce,
    "Expected viewCloseSpy to be called once but was called
      #{viewCloseSpy.callCount} times"
  )
)

test('when clicking the close button, the view gets closed', ->
  viewCloseSpy = sinon.spy(Backbone.Views.ChooseUserView::, 'hideView')

  view = new Backbone.Views.ChooseUserView()
  Helpers.renderViewToTestContainer(view)

  view.$el.find('.close').trigger('click')
  viewCloseSpy.restore()

  assert.ok(
    viewCloseSpy.calledOnce,
    "Expected viewCloseSpy to be called once but was called
      #{viewCloseSpy.callCount} times"
  )
)
