assert = chai.assert

createAndShowNarrativeViewForNarrative = (narrative) ->
  view = new Backbone.Views.NarrativeView(narrative: narrative)
  view.render()
  $('#test-container').html(view.el)
  return view

suite('Narrative View')

test("When rendering a markdown narrative, should be rendered as HTML", ->
  narrativeAttributes = 
    content: "This is *some* markdown\n\nShould be good."

  narrative = new Backbone.Models.Narrative(narrativeAttributes)
  view = createAndShowNarrativeViewForNarrative(narrative)

  expectRenderedAs = "<p>This is <em>some</em> markdown</p>\n<p>Should be good.</p>"
  renderedAs = $('#test-container').find('.content-text').text()
  
  assert.equal renderedAs.replace(/^\s+|\s+$/g, ''), expectRenderedAs.replace(/^\s+|\s+$/g, '')
)

test("Blurring narrative triggers delaySave", (done)->
  narrative = new Backbone.Models.Narrative()

  delayedSaveStub = sinon.stub(Backbone.Views.NarrativeView::, 'delaySave')

  view = createAndShowNarrativeViewForNarrative(narrative)

  # Edit the title
  newContent = 'Some exciting new content'
  $.when(
    $('#test-container').find(".content-text-field").text(newContent).trigger('blur')
  ).done(->
    assert.ok(
      delayedSaveStub.calledOnce,
      "Expected delaySave to be called once, but was called #{delayedSaveStub.callCount}"
    )
    delayedSaveStub.restore()
    done()
  )
)