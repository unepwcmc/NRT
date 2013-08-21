assert = chai.assert

suite('Narrative Model')

test('.toJSON returns the section: as section._id instead of the model attributes', ->
  sectionId = Helpers.findNextFreeId('Section')
  section = new Backbone.Models.Section(
    _id: sectionId
  )
  narrative = new Backbone.Models.Narrative(
    section: section
  )

  assert.strictEqual narrative.toJSON().section, sectionId
)

