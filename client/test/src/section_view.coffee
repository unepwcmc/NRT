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
    if subView.constructor.name is "VisualisationView" and subView.visualisation is visualisation
      subViewExists = true

  assert subViewExists, "could not find visualisation sub-view for section"

  view.close()
)

test("Can see the section narrative", ->
  narrative = new Backbone.Models.Narrative()
  section = new Backbone.Models.Section(narratives: [narrative])

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "NarrativeView" and subView.narrative is narrative
      subViewExists = true

  assert subViewExists, "could not find narrative sub-view for section"

  view.close()
)

test(".addNarrative creates a narrative record on the section", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.equal section.get('narratives').models.length, 0

  view.addNarrative()

  assert.equal section.get('narratives').models.length, 1
)

test("Can edit the section")
test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
