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

test('updates when section list changes')
