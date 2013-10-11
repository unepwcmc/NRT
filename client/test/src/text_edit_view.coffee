suite('Text Edit View')

test('When clicking the view, it opens a TextEditingView', ->
  textEditView = new Backbone.Views.TextEditView(
    model: new Backbone.Model(text: ''),
    attributeName: 'text'
  )

  $(textEditView.el).trigger('click')

  assert.strictEqual textEditView.editingView.constructor.name, 'TextEditingView'
  textEditView.close()
)

test('Given a model where getPage returns a page in draft mode,
  it renders the TextEditView in edit mode', ->
  page = Factory.page()
  section = Factory.section(title: 'A section')
  section.set('indicator', null)

  page.set('sections', [section])
  page.set('is_draft', true)

  textEditView = new Backbone.Views.TextEditView(
    model: page.get('sections').at(0)
    attributeName: 'text'
  )

  Helpers.renderViewToTestContainer(textEditView)

  assert textEditView.editMode, "Expected TextEditView to have edit mode set as true"

  textEditView.close()
)

test('If the model has no .getPage method, edit mode is set to true', ->
  model = new Backbone.Model()

  textEditView = new Backbone.Views.TextEditView(
    model: model
    attributeName: 'text'
  )

  Helpers.renderViewToTestContainer(textEditView)

  assert.isTrue textEditView.editMode, "Expected edit mode to be set to true"

  textEditView.close()
)

test('When finishing editing it should trigger save on the model', ->
  model = new Backbone.Models.Section(text: '')
  modelSaveStub = sinon.stub(model, 'save', ->
    return {
      done: ->
    }
  )

  textEditView = new Backbone.Views.TextEditView(
    model: model
    attributeName: 'text'
  )

  $(textEditView.el).trigger('click')
  $('.modal').trigger('click')

  Helpers.assertCalledOnce(modelSaveStub)
  textEditView.close()
)
