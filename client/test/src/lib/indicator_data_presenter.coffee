suite('IndicatorDataPresenter')

test('.getHeadlineFromData given a row of indicator data and the indicator definition, 
returns the headline values', ->
  indicatorData =
    theValue: "22.4"
    text: "Passable"

  indicatorDefinition =
    short_unit: 'ug/m3'
    yAxis: 'theValue'

  headline = Nrt.Presenters.IndicatorDataPresenter.getHeadlineFromData(
    indicatorData, indicatorDefinition
  )

  assert.strictEqual headline.text, indicatorData.text,
    "Expected the headline to include the indicator data text"
  assert.strictEqual headline.value, indicatorData.theValue,
    "Expected the headline to include the indicator data value"
  assert.strictEqual headline.unit, indicatorDefinition.short_unit,
    "Expected the headline to include the indicator data unit"
)

test('.getSubIndicatorValueFromData returns the subIndicatorField value of the data', ->
  indicatorData=
    station: 'Zakher'
  indicatorDefinition =
    subIndicatorField: 'station'

  value = Nrt.Presenters.IndicatorDataPresenter.getSubIndicatorValueFromData(
    indicatorData, indicatorDefinition
  )
  
  assert.strictEqual value, indicatorData.station
)
