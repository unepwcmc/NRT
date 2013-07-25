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

test(".addNarrative creates a narrative record on the section", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('narrative')

  view.addNarrative()

  assert.equal section.get('narrative').constructor.name, 'Narrative'
)

test(".addNarrative renders in edit mode and .resize is called", ->

  spy = sinon.spy(Backbone.Views.NarrativeView::, 'resize')

  section = new Backbone.Models.Section()
  view = createAndShowSectionViewForSection(section)
  narrative = view.addNarrative()
  narrativeView = view.subViews[0]  # Is there a getSubView('view name') method?
  
  assert.isTrue narrative.get('editing')
  sinon.assert.calledOnce(spy, "resize")
)



test("Can edit the section")
test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
