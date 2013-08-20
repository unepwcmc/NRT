window.Helpers ||= {}

Helpers.findNextFreeId = (modelName) ->
  Helpers.modelIds ||= {}
  Helpers.modelIds[modelName] ||= 0

  while Backbone.Models[modelName].findOrCreate(Helpers.modelIds[modelName])?
    Helpers.modelIds[modelName] = Helpers.modelIds[modelName] + 1

  return Helpers.modelIds[modelName]

Helpers.factoryIndicator = ->
  new Backbone.Models.Indicator(
    _id: Helpers.findNextFreeId('Indicator')
  )

Helpers.factorySectionWithIndicator = ->
  new Backbone.Models.Section(
    _id: Helpers.findNextFreeId('Section')
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

