suite('Permissions View')

test('when logged in and given a ownable model with no owner, I see "Choose owner"', ->
  ownable = Factory.indicator()

  view = new Backbone.Views.PermissionsView(ownable: ownable, user: Factory.user())

  Helpers.renderViewToTestContainer(view)

  assert.match $("#test-container").text(), /Choose owner/
)

test('when given a ownable model with an owner, I see the owners name', ->
  ownable = Factory.indicator(
    owner: Factory.user(name: "Lovely Owner")
  )

  view = new Backbone.Views.PermissionsView(ownable: ownable)

  Helpers.renderViewToTestContainer(view)

  assert.match $("#test-container").text(), new RegExp(ownable.get('owner').get('name'))
  assert.notMatch $("#test-container").text(), /Choose owner/

  view.close()
)

test("when logged in and I click 'change' owner, it adds a choose user sub view", ->
  view = new Backbone.Views.PermissionsView(ownable: Factory.indicator(), user: Factory.user())

  Helpers.renderViewToTestContainer(view)

  assert.isUndefined(
    view.chooseUserView,
    "View was expected to not have a ChooseUser sub view"
  )

  view.$el.find('.change-owner').trigger('click')

  assert.isDefined(
    view.chooseUserView,
    "View was expected to have a ChooseUser sub view"
  )
  assert.ok(
    view.chooseUserView.constructor.name,
    "ChooseUserView",
    "Expected view.chooseUserView to be a ChooseUserView"
  )

  view.close()
)

test(".setOwner should set the owner attribute on the ownable model,
  call save and re-render", ->
  indicator = Factory.indicator()
  indicatorSaveStub = sinon.stub(indicator, 'save')

  viewRenderStub = sinon.spy(Backbone.Views.PermissionsView::, 'render')
  view = new Backbone.Views.PermissionsView(
    permissions: {},
    ownable: indicator
  )

  assert.ok(
    viewRenderStub.calledOnce,
    "Expected view to be rendered once in initialize, but rendered
    #{viewRenderStub.callCount} times"
  )

  newOwner = Factory.user()
  view.setOwner(newOwner)

  assert.strictEqual indicator.get('owner').cid, newOwner.cid
  assert.ok(
    indicatorSaveStub.calledOnce,
    "Expected indicator save to be called once but was called
    #{indicatorSaveStub.callCount} times"
  )
  assert.strictEqual(
    viewRenderStub.callCount, 2,
    "Expected view to be rendered twice, but rendered
    #{viewRenderStub.callCount} times"
  )

  Backbone.Views.PermissionsView::render.restore()
)
