assert = chai.assert

suite('Visualisation Model')

test('.formatDataForChart parses indicator data correctly', ->
  visualisation = new Backbone.Models.Visualisation(
    data:
      features: [
        attributes:
          Percentage: 28
          Year: 2010
      ,
        attributes:
          Percentage: 26
          Year: 2011
      ]
  )

  expectedData = [
    Percentage: 28
    Year: 2010
  ,
    Percentage: 26
    Year: 2011
  ]

  assert(
    _.isEqual(visualisation.formatDataForChart(), expectedData),
    "Parsed data #{visualisation.formatDataForChart()} is not equal to #{expectedData}"
  )
)