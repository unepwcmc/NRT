suite('Text Edit View')

test('When clicking the view, it opens a TextEditingView', ->
  textEditView = new Backbone.Views.TextEditView(
    model: new Backbone.Models.Section(text: ''),
    attributeName: 'text'
  )

  $(textEditView.el).trigger('click')

  assert.strictEqual textEditView.editingView.constructor.name, 'TextEditingView'
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

test("When the section has no text, and is in edit mode, it should render 'Type your text'", ->
  model = new Backbone.Models.Section(text: '')
  modelSaveStub = sinon.stub(model, 'isEditable', ->
    return true
  )

  textEditView = new Backbone.Views.TextEditView(
    model: model
    attributeName: 'text'
  )

  Helpers.renderViewToTestContainer(textEditView)

  text = $('#test-container').find('.show-content').text()
  assert.match(text, /Type your text/)

  textEditView.close()
)
