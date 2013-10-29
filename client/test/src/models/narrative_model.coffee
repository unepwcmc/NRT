assert = chai.assert

suite('Narrative Model')

test('.toJSON returns the section: as section._id instead of the model attributes', ->
  sectionId = Factory.findNextFreeId('Section')
  section = new Backbone.Models.Section(
    _id: sectionId
  )
  narrative = new Backbone.Models.Narrative(
    section: section
  )

  assert.strictEqual narrative.toJSON().section, sectionId
)

test('.getPage should get the parent page', ->
  narrative = new Backbone.Models.Narrative()
  page = Factory.page(sections: [{title: 'A section', narrative: narrative}])

  assert.strictEqual(
    narrative.getPage().cid,
    page.cid,
    "Expected the Narrative page to be the same as page"
  )
)

test('EditModeMixin is mixed in', ->
  narrative = new Backbone.Models.Narrative()

  assert.isDefined narrative.isEditable, 'Expected narrative to have method .isEditable'
)
