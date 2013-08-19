window.Helpers ||= {}

indicatorId = 0
Helpers.factoryIndicator = ->
  indicatorId = indicatorId + 1
  new Backbone.Models.Indicator(
    _id: indicatorId
  )

Helpers.factorySectionWithIndicator = ->
  new Backbone.Models.Section(
    indicator: Helpers.factoryIndicator()
  )

Helpers.factoryVisualisationWithIndicator = ->
  section = Helpers.factorySectionWithIndicator()
  new Backbone.Models.Visualisation(
    indicator: Helpers.factoryIndicator()
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

