window.Helpers ||= {}

indicatorId = 0
Helpers.factorySectionWithIndicator = ->
  indicatorId = indicatorId + 1
  new Backbone.Models.Section(
    indicator: new Backbone.Models.Indicator(
      _id: indicatorId
    )
  )

Helpers.factoryVisualisationWithIndicator = ->
  section = Helpers.factorySectionWithIndicator()
  new Backbone.Models.Visualisation(
    section: section
  )

Helpers.renderViewToTestContainer = (view) ->
  view.render()
  $('#test-container').html(view.el)

window.Helpers.SinonServer ||= {}

# Used to extend Sinon Servers with common response method
Helpers.SinonServer.respondWithJson = (jsonData) ->
  @requests[0].respond(
    200,
    { "Content-Type": "application/json" },
    JSON.stringify(jsonData)
  )

