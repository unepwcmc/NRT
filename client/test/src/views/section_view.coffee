assert = chai.assert

createAndShowSectionViewForSection = (section) ->
  view = new Backbone.Views.SectionView(section: section)
  Helpers.renderViewToTestContainer(view)
  return view

suite('Section View')

test("When showing a section without a title or indicator, you see 'New Section'", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.match(
    $('#test-container').text(),
    new RegExp(".*New Section.*")
  )

  view.close()
)

test("When showing a section without a title or indicator, you see
  two buttons: 'Add text', 'Add visualisation'", ->
  section = new Backbone.Models.Section()

  view = createAndShowSectionViewForSection(section)

  assert.match(
    $('#test-container').find('.add-narrative').text(),
    new RegExp(".*Add text.*")
  )

  assert.match(
    $('#test-container').find('.add-visualisation').text(),
    new RegExp(".*Add visualisation.*")
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

test("When section has narrative, can see the narrative", ->
  narrative = new Backbone.Models.Narrative()
  section = new Backbone.Models.Section(title: 'title', narrative: narrative)

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == "TextEditView" and subView.model is narrative
      subViewExists = true

  assert subViewExists, "could not find narrative sub-view for section"

  view.close()
)

test(".addNarrative creates a narrative record on the section", ->
  section = Factory.section()

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('narrative')

  view.addNarrative()

  assert.equal section.get('narrative').constructor.name, 'Narrative'
  assert.equal section.get('narrative').get('section_id'), section.get('id')

  view.close()
)

test(".chooseIndicatorForVisualisation creates a modal indicator selector view", ->
  section = new Backbone.Models.Section(id: 12, title: 'title')

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('indicator')

  view.chooseIndicatorForVisualisation()

  assert.strictEqual $('#test-container .modal').length, 1, "modal DOM element exists"

  view.close()
)

test("Can see the section visualisation", ->
  visualisation = Factory.visualisation()
  visualisation.set('data', results: [])
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
    indicator: Factory.indicator()
  )

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('visualisation')

  view.createVisualisation()

  assert.equal section.get('visualisation').constructor.name, 'Visualisation'

  view.close()
)
