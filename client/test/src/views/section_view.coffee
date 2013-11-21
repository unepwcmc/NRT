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

  Helpers.viewHasSubViewOfClass view, "TextEditView"

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

  assert.strictEqual $('.modal').length, 1, "modal DOM element exists"

  view.close()
)

test(".chooseIndicatorForVisualisation binds createVisualisation to the
indicator selector view 'indicatorSelected' event", (done) ->
  section = new Backbone.Models.Section(id: 12, title: 'title')

  view = createAndShowSectionViewForSection(section)

  sinon.stub(view, 'createVisualisation', (indicator)->
    assert.strictEqual indicator.cid, selectedIndicator.cid,
      "Expected createVisualisation to be called with the selected indicator"
    done()
  )

  view.chooseIndicatorForVisualisation()

  selectedIndicator = Factory.indicator()

  view.indicatorSelectorView.trigger('indicatorSelected', selectedIndicator)

  view.close()
)

test("Can see the section visualisation", ->
  visualisation = Factory.visualisation()
  visualisation.set('data', results: [])
  section = new Backbone.Models.Section(title: 'title', visualisation: visualisation)

  view = createAndShowSectionViewForSection(section)

  Helpers.viewHasSubViewOfClass view, "VisualisationView"

  view.close()
)

test(".createVisualisation creates a visualisation on the section with an indicator set
  and calls editVisualisation", ->
  section = Factory.section()

  view = new Backbone.Views.SectionView(section: section)

  assert.isNull section.get('visualisation')

  indicator = Factory.indicator()

  editVisualisationStub = sinon.stub(view, 'editVisualisation', ->)
  getIndicatorDataStub = sinon.stub(Backbone.Models.Visualisation::, 'getIndicatorData', ->)

  view.createVisualisation(indicator)

  try
    assert.equal section.get('visualisation').constructor.name, 'Visualisation'
    assert.strictEqual(
      section.get('visualisation').get('section').cid,
      section.cid
    )

    assert.strictEqual(
      section.get('visualisation').get('indicator').cid,
      indicator.cid
    )

    Helpers.assertCalledOnce(editVisualisationStub)
  catch e
    throw e
  finally
    view.close()
    getIndicatorDataStub.restore()
)

test(".destroySection calls destroy on the section, save on the parent page,
  and closes the view", ->
  page = Factory.page(sections: [{}])
  pageSaveStub = sinon.stub(page, 'save', (attributes, options)->
    options.success()
  )
  collection = page.get('sections')

  view = new Backbone.Views.SectionView(section: collection.models[0])

  viewCloseSpy = sinon.spy(view, 'close')

  view.destroySection()

  assert.lengthOf collection.models, 0,
    "Expected section collection to be empty"

  Helpers.assertCalledOnce(pageSaveStub)
  Helpers.assertCalledOnce(viewCloseSpy)
)

test(".editVisualisation does not open a report edit visualisation view 
if section.isEditable returns false", ->
  section = Factory.section()
  section.isEditable = ->
    return false

  sinon.spy(Backbone.Views, "ReportEditVisualisationView")

  view = new Backbone.Views.SectionView(section: section)

  view.editVisualisation()

  try
    assert.strictEqual Backbone.Views.ReportEditVisualisationView.callCount, 0,
      "Expected a ReportEditVisualisationView not to be created"
  finally
    view.close()
    Backbone.Views.ReportEditVisualisationView.restore()

)
