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

test(".addNarrative creates a narrative record on the section and sets editing to true", ->
  section = new Backbone.Models.Section(id: 12, title: 'title')

  view = createAndShowSectionViewForSection(section)

  assert.isNull section.get('narrative')

  view.addNarrative()

  assert.equal section.get('narrative').constructor.name, 'Narrative'
  assert.equal section.get('narrative').get('section_id'), section.get('id')
  assert.equal section.get('narrative').get('editing'), true

  view.close()
)

test(".startTitleEdit sets the title to 'New Section' and calls render", ->
  section = new Backbone.Models.Section()
  view = createAndShowSectionViewForSection(section)

  view.startTitleEdit()

  assert.equal section.get('title'), 'New Section'
  view.close()
)

test(".addNarrative calls render and resize in edit mode", ->

  spy = sinon.spy(Backbone.Views.NarrativeView::, 'resize')

  section = new Backbone.Models.Section(title: 'title')
  view = createAndShowSectionViewForSection(section)
  view.addNarrative()
  narrativeView = view.subViews[0]  # Is there a getSubView('view name') method?
  
  assert.isTrue view.section.get('narrative').get('editing')
  sinon.assert.calledOnce(spy, "resize")

  Backbone.Views.NarrativeView::resize.restore()
)

test("Can see the section visualisation", ->
  visualisation = new Backbone.Models.Visualisation()
  section = new Backbone.Models.Section(title: 'title', visualisation: visualisation)

  view = createAndShowSectionViewForSection(section)

  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name is "VisualisationView" and subView.visualisation is visualisation
      subViewExists = true

  assert subViewExists, "could not find visualisation sub-view for section"

  view.close()
)

test("Can edit the section title", (done)->
  oldTitle = "old title"
  section = new Backbone.Models.Section(title: oldTitle)

  sectionSaveSpy = sinon.spy(Backbone.Models.Section::, 'save')

  view = createAndShowSectionViewForSection(section)

  # Open the edit view
  $.when($('#test-container').find('h2 .add-content').trigger('click')).done(->
    # Edit the title
    newTitle = 'new title'
    $('#test-container').find("input[value=\"#{oldTitle}\"]").val(newTitle)
    
    $.when($('#test-container').find(".save-content").trigger('click')).done(->
      assert.equal section.get('title'), newTitle
      sinon.assert.calledOnce(sectionSaveSpy, "save")

      sectionSaveSpy.restore()
      view.close()
      done()
    )
  )
)

test("Can view report containing this section")
test("Can navigate to Dashboard, Reports, Indicators and Bookmarks")
