assert = chai.assert

suite('Edit Mode Mixin')

test('.isEditable returns true if the parent page has is_draft set to true', ->
  page = Factory.page()
  section = Factory.section(title: 'A section')
  section.set('indicator', null)

  page.set('sections', [section])
  page.set('is_draft', true)

  assert.isTrue section.isEditable(), "Expected Section to be editable"
)

test('.isEditable returns false if the parent page has is_draft set to false', ->
  page = Factory.page()
  section = Factory.section(title: 'A section')
  section.set('indicator', null)

  page.set('sections', [section])
  page.set('is_draft', false)

  assert.isFalse section.isEditable(), "Expected Section to not be editable"
)

test('.isEditable returns true if the parent page has is_draft undefined', ->
  page = Factory.page()
  section = Factory.section(title: 'A section')
  section.set('indicator', null)

  page.set('sections', [section])

  assert.isTrue section.isEditable(), "Expected Section to be editable"
)
