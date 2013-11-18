window.Nrt ||= {}
window.Nrt.Presenters ||= {}

class Nrt.Presenters.IndicatorDataPresenter

  @getHeadlineFromData: (data, indicatorDefinition) ->
    value: data[indicatorDefinition.yAxis]
    text: data.text
    unit: indicatorDefinition.short_unit
  
  @getSubIndicatorValueFromData: (data, indicatorDefinition) ->
    data[indicatorDefinition.subIndicatorField]
