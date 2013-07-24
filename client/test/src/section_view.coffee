assert = chai.assert

createAndShowSectionViewForSection = (section) ->
  view = new Backbone.Views.SectionView(section: section)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Section View')

test("Can see the section title", ->
  title = "My Lovely Section"
  section = new Backbone.Models.Section(title: title)

  view = createAndShowSectionViewForSection(section)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*#{title}.*")
  )

  view.close()
)

test("Can see the section visualisation", ->
  visualisation = new Backbone.Models.Visualisation()
  section = new Backbone.Models.Section(visualisations: [visualisation])

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "VisualisationView"
      subViewExists = true

  assert subViewExists

  view.close()
)

test("Can see the section narrative")
test("Can edit the section")
test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
