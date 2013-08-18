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

test(".getIndicatorData populates the 'data' attribute and triggers 'dataFetched'", (done)->
  visualisation = Helpers.factoryVisualisationWithIndicator()
  section = visualisation.get('section')

  server = sinon.fakeServer.create()

  visualisation.on('dataFetched', ->
    assert.isDefined visualisation.get('data')
    visualisation.off('dataFetched')
    done()
  )
  visualisation.getIndicatorData()

  assert.equal(
    server.requests[0].url,
    "/api/indicators/#{section.get('indicator').get('id')}/data"
  )

  Helpers.SinonServer.respondWithJson.call(server, {some: 'data'})

  server.restore()
)
