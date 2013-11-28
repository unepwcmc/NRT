window.Nrt ||= {}
window.Nrt.Presenters ||= {}

class Nrt.Presenters.SubIndicatorDataPresenter
  constructor: (@indicatorDefinition) ->

  getHeadlineFromData: (data) ->
    value: data[@indicatorDefinition.yAxis]
    text: data.text
    unit: @indicatorDefinition.subIndicatorUnit

  getSubIndicatorIdentifier: (data) ->
    data[@indicatorDefinition.subIndicatorField]
