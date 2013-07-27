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

test("When section has narrative, can see the narrative", ->
  narrative = new Backbone.Models.Narrative()
  section = new Backbone.Models.Section(narrative: narrative)

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "NarrativeView" and subView.narrative is narrative
      subViewExists = true

  assert subViewExists, "could not find narrative sub-view for section"

  view.close()
)

test("When section has no narrative, I should see the 'add-narrative' element", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.equal(
    $('#test-container').find('.add-narrative').length, 1, "Could not see .add-narrative element"
  )
)

test(".addNarrative creates a narrative record on the section and sets editing to true", ->
  section = new Backbone.Models.Section(id: 12)

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('narrative')

  view.addNarrative()

  assert.equal section.get('narrative').constructor.name, 'Narrative'
  assert.equal section.get('narrative').get('section_id'), section.get('id')
  assert.equal section.get('narrative').get('editing'), true
)

test(".addNarrative calls render and resize in edit mode", ->

  spy = sinon.spy(Backbone.Views.NarrativeView::, 'resize')

  section = new Backbone.Models.Section()
  view = createAndShowSectionViewForSection(section)
  view.addNarrative()
  narrativeView = view.subViews[0]  # Is there a getSubView('view name') method?
  
  assert.isTrue view.section.get('narrative').get('editing')
  sinon.assert.calledOnce(spy, "resize")

  Backbone.Views.NarrativeView::resize.restore()
)

test("Can see the section visualisation", ->
  visualisation = new Backbone.Models.Visualisation()
  section = new Backbone.Models.Section(visualisation: visualisation)

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name is "VisualisationView" and subView.visualisation is visualisation
      subViewExists = true

  assert subViewExists, "could not find visualisation sub-view for section"

  view.close()
)

test(".addVisualisation creates a visualisation record on the section", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('visualisation')

  view.addVisualisation()

  assert.equal section.get('visualisation').constructor.name, 'Visualisation'
)

test("Can edit the section")
test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
