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

test("When rendering a markdown narrative, should be rendered as HTML", ->
  narrativeAttributes = 
    content: "This is *some* markdown\n\nShould be good."

  narrative = new Backbone.Models.Narrative(narrativeAttributes)
  view = createAndShowNarrativeViewForNarrative(narrative)

  expectRenderedAs = "<p>This is <em>some</em> markdown</p>\n<p>Should be good.</p>"
  renderedAs = $('#test-container').find('.content-text').html()
  
  assert.equal renderedAs.replace(/^\s+|\s+$/g, ''), expectRenderedAs.replace(/^\s+|\s+$/g, '')
)

