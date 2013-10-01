suite('Permissions View')

test('when given a permissions object with no owner, I see "Choose owner"', ->
  permissions = {}

  view = new Backbone.Views.PermissionsView(permissions: permissions)

  Helpers.renderViewToTestContainer(view)

  assert.match $("#test-container").text(), /Choose owner/
)

test('when given a permissions object with an owner, I see the owners name', ->
  permissions = {
    owner: Factory.user(name: "My lovely user")
  }

  view = new Backbone.Views.PermissionsView(permissions: permissions)

  Helpers.renderViewToTestContainer(view)

  assert.match $("#test-container").text(), new RegExp(permissions.owner.get('name'))
  assert.notMatch $("#test-container").text(), /Choose owner/
)

test("when I click 'change' owner, it adds a choose user sub view", ->
  view = new Backbone.Views.PermissionsView(permissions: {})

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
)
