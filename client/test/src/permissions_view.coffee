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

test("when I click 'change' owner, it adds a choose owner sub view", ->
  view = new Backbone.Views.PermissionsView(permissions: {})

  Helpers.renderViewToTestContainer(view)

  assert.notOk(
    Helpers.viewHasSubViewOfClass(view, 'ChooseOwnerView'),
    "View was expected to not have a ChooseOwner sub view"
  )

  view.$el.find('.change-owner').trigger('click')

  assert.ok(
    Helpers.viewHasSubViewOfClass(view, 'ChooseOwnerView'),
    "View does not have a ChooseOwner sub view"
  )
)
