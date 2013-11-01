suite('Text Editing View')

test('.closeViewAndModal fires the close event with the new text', ->
  textEditingView = new Backbone.Views.TextEditingView(
    content: "hat"
    tagName: 'div'
    position:
      top: 0
      left: 0
  )

  newText = 'new text'
  closeSpy = sinon.spy((returnedText) ->
    assert.strictEqual returnedText, newText
  )
  textEditingView.on('close', closeSpy)

  textEditingView.$el.text('new text')
  textEditingView.closeViewAndModal()

  Helpers.assertCalledOnce(closeSpy)
  textEditingView.close()
)

test('.close removes all traces of the medium editor', ->
  textEditingView = new Backbone.Views.TextEditingView(
    model: new Backbone.Model(text: ''),
    attributeName: 'text'
    tagName: 'div'
    position:
      top: 0
      left: 0
  )

  textEditingView.close()

  assert.lengthOf $('.medium-editor-toolbar'), 0
)
