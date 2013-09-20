suite('Text Edit View')

test('When clicking the view, it opens a TextEditingView', ->
  textEditView = new Backbone.Views.TextEditView(
    model: new Backbone.Model(text: ''),
    attributeName: 'text'
  )

  $(textEditView.el).trigger('click')

  assert.strictEqual textEditView.editingView.constructor.name, 'TextEditingView'
)
