assert = chai.assert

createAndShowSectionNavigationView = (sections) ->
  view = new Backbone.Views.SectionNavigationView(sections:sections)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Section Navigation View')

test('shows the titles of each section', ->
  title1 = 'section 1'
  title2 = 'section 2'
  sections = new Backbone.Collections.SectionCollection([{
    title: title1
  },{
    title: title2
  }])

  view = createAndShowSectionNavigationView(sections)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title1}.*")
  )

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title2}.*")
  )
  view.close()
)

test('updates when section list changes', ->
  title1 = 'section 1'
  title2 = 'section 2'
  title3 = 'section 3'
  
  sections = new Backbone.Collections.SectionCollection([{
    title: title1
  },{
    title: title2
  }])

  view = createAndShowSectionNavigationView(sections)

  sections.add
    title: title3

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title1}.*")
  )

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title2}.*")
  )

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title3}.*")
  )
  view.close()
)

test('.getOrderedCids returns the section CIDs in the order they are in the DOM', ->
  sections = new Backbone.Collections.SectionCollection([{
    title: 'Section 1'
  }, {
    title: 'Section 2'
  }])

  view = createAndShowSectionNavigationView(sections)
  orderedCids = view.getOrderedCids()

  assert.lengthOf orderedCids, 2
  assert.strictEqual sections.get(orderedCids[0]).get('title'), 'Section 1'
  assert.strictEqual sections.get(orderedCids[1]).get('title'), 'Section 2'
)
