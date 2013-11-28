suite('SubIndicatorDataPresenter')

test('.getHeadlineFromData given a row of indicator data and the indicator definition,
  returns the headline values', ->
  indicatorData =
    theValue: "22.4"
    text: "Passable"

  indicatorDefinition =
    subIndicatorUnit: 'ug/m3'
    yAxis: 'theValue'

  presenter = new Nrt.Presenters.SubIndicatorDataPresenter(indicatorDefinition)

  headline = presenter.getHeadlineFromData(indicatorData)

  assert.strictEqual headline.text, indicatorData.text,
    "Expected the headline to include the indicator data text"
  assert.strictEqual headline.value, indicatorData.theValue,
    "Expected the headline to include the indicator data value"
  assert.strictEqual headline.unit, indicatorDefinition.subIndicatorUnit,
    "Expected the headline to include the indicator data unit"
)

test('.getSubIndicatorIdentifier returns the subIndicatorField value of the data', ->
  indicatorData=
    station: 'Zakher'
  indicatorDefinition =
    subIndicatorField: 'station'

  presenter = new Nrt.Presenters.SubIndicatorDataPresenter(indicatorDefinition)

  value = presenter.getSubIndicatorIdentifier(indicatorData)

  assert.strictEqual value, indicatorData.station
)
