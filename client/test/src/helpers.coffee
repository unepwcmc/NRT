window.Helpers ||= {}

Helpers.findNextFreeId = (modelName) ->
  Helpers.modelIds ||= {}
  Helpers.modelIds[modelName] ||= 0

  while Backbone.Models[modelName].findOrCreate(Helpers.modelIds[modelName])?
    Helpers.modelIds[modelName] = Helpers.modelIds[modelName] + 1

  return Helpers.modelIds[modelName]

Helpers.factoryIndicator = (attributes = {}) ->
  attributes._id ||= Helpers.findNextFreeId('Indicator')
  attributes.indicatorDefinition ||=
    fields: []
  new Backbone.Models.Indicator(
    attributes
  )

Helpers.factorySectionWithIndicator = ->
  new Backbone.Models.Section(
    _id: Helpers.findNextFreeId('Section')
    indicator: Helpers.factoryIndicator()
  )

Helpers.factoryVisualisationWithIndicator = (attributes = {}) ->
  attributes.indicator ||= Helpers.factoryIndicator()
  attributes.data ||=
    results: []
    
  new Backbone.Models.Visualisation(attributes)

Helpers.renderViewToTestContainer = (view) ->
  view.render()
  $('#test-container').html(view.el)

window.Helpers.SinonServer ||= {}

Helpers.viewHasSubViewOfClass = (view, subViewClassName) ->
  subViewExists = false
  for subView in view.subViews
    if subView.constructor.name == subViewClassName
      subViewExists = true
  return subViewExists

# Used to extend Sinon Servers with common response method
Helpers.SinonServer.respondWithJson = (jsonData) ->
  @requests[0].respond(
    200,
    { "Content-Type": "application/json" },
    JSON.stringify(jsonData)
  )

