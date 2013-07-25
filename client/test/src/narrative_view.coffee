assert = chai.assert

createAndShowNarrativeViewForNarrative = (narrative) ->
  view = new Backbone.Views.NarrativeView(narrative: narrative)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Narrative View')

test('.saveNarrative should update the content and editing state', ->
  narrative = new Backbone.Models.Narrative(editing: true)
  view = createAndShowNarrativeViewForNarrative(narrative)

  newText = "this is the new narrative text"
  $('#test-container').find(".content-text-field").val(newText)
  view.saveNarrative()

  assert.equal narrative.get('content'), newText
  assert.equal narrative.get('editing'), false
)

test('.startEdit should set editing to true', ->
  narrative = new Backbone.Models.Narrative(editing: false)
  view = createAndShowNarrativeViewForNarrative(narrative)

  view.startEdit()

  assert.equal narrative.get('editing'), true
)
