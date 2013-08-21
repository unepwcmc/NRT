assert = chai.assert

createAndShowSectionViewForSection = (section) ->
  view = new Backbone.Views.SectionView(section: section)
  Helpers.renderViewToTestContainer(view)
  return view

suite('Section View')

test("When showing a section without a title or indicator, you see 'Start typing title or add an indicator'", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.match(
    $('#test-container').find('.add-title').text(),
    new RegExp(".*Start typing your new section title.*")
  )

  assert.match(
    $('#test-container').find('.choose-indicator').text(),
    new RegExp(".*reference an indicator.*")
  )

  view.close()
)

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

test("Can see the section indicator title", ->
  indicatorTitle = "My Lovely Indicator"
  section = new Backbone.Models.Section(indicator: {title: indicatorTitle})

  view = createAndShowSectionViewForSection(section)

  assert.match(
    $('#test-container').find('h2').text(),
    new RegExp(".*#{indicatorTitle}.*")
  )

  view.close()
)

test("When section has narrative, can see the narrative", ->
  narrative = new Backbone.Models.Narrative()
  section = new Backbone.Models.Section(title: 'title', narrative: narrative)

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "NarrativeView" and subView.narrative is narrative
      subViewExists = true

  assert subViewExists, "could not find narrative sub-view for section"

  view.close()
)

test("When section has no narrative, I should see the 'add-narrative' element", ->
  section = new Backbone.Models.Section(title: 'title')

  view = createAndShowSectionViewForSection(section)

  assert.equal(
    $('#test-container').find('.add-narrative').length, 1, "Could not see .add-narrative element"
  )
  view.close()
)

test(".addNarrative creates a narrative record on the section", ->
  section = new Backbone.Models.Section(id: 12, title: 'title')

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('narrative')

  view.addNarrative()

  assert.equal section.get('narrative').constructor.name, 'Narrative'
  assert.equal section.get('narrative').get('section_id'), section.get('id')

  view.close()
)

test(".startTitleEdit sets the title to 'New Section' and calls render", ->
  section = new Backbone.Models.Section()
  view = createAndShowSectionViewForSection(section)

  view.startTitleEdit()

  assert.equal section.get('title'), 'New Section'
  view.close()
)

test("Can see the section visualisation", ->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  visualisation.set('data', [])
  section = new Backbone.Models.Section(title: 'title', visualisation: visualisation)

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name is "VisualisationView" and subView.visualisation is visualisation
      subViewExists = true

  assert subViewExists, "could not find visualisation sub-view for section"

  view.close()
)

test(".createVisualisation creates a visualisation record on the section
  and saves it", ->
  section = new Backbone.Models.Section(
    title: 'This title is'
    indicator: Helpers.factoryIndicator()
  )

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('visualisation')

  view.createVisualisation()

  assert.equal section.get('visualisation').constructor.name, 'Visualisation'

  view.close()
)

test(".editVisualisation creates a visualisation if none currently
  exists", ->
  section = new Backbone.Models.Section(
    title: 'This title is'
    indicator: Helpers.factoryIndicator()
  )

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('visualisation')

  view.editVisualisation()

  assert.equal section.get('visualisation').constructor.name, 'Visualisation'

  view.close()
)

test("Blurring title triggers delaySave", (done)->
  oldTitle = "old title"
  report = new Backbone.Models.Report({
    sections: [
      new Backbone.Models.Section(title: oldTitle)
    ]
  })
  section = report.get('sections').models[0]

  delaySaveStub = sinon.stub(Backbone.Views.TextEditView::, 'delaySave')

  view = createAndShowSectionViewForSection(section)

  # Edit the title
  newTitle = 'new title'
  $.when(
    $('#test-container').find(".content-text-field").text(newTitle).trigger('blur')
  ).done(->
    assert.ok(
      delaySaveStub.calledOnce,
      "Expected delaySave to be called once, but was called #{delaySaveStub.callCount}"
    )
    delaySaveStub.restore()
    done()
  )
)

test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
