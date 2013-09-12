assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model

suite('Indicator show')

test("When given a valid indicator, I should get a 200 and see the title", (done)->
  indicatorTitle = "Dat test indicator"
  indicator = new Indicator(title: indicatorTitle)

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match body, new RegExp(".*#{indicatorTitle}.*")
      done()
  )
)

test('An indicator can be downloaded as a CSV file', (done) ->
  data = [
    {
      "year": 2000,
      "value": 3
    }, {
      "year": 2001,
      "value": 4
    }, {
      "year": 2002,
      "value": 4
    }
  ]

  expectedData = """
    "year","value"\r\n"2000","3"\r\n"2001","4"\r\n"2002","4"\r\n
  """

  indicator = new Indicator(
    indicatorDefinition:
      xAxis: 'year'
      yAxis: 'value'
      enviroportalId: 14
  )
  indicatorData = new IndicatorData(
    enviroportalId: 14, data: data
  )

  async.parallel([
        (cb) -> indicator.save(cb)
      ,
        (cb) -> indicatorData.save(cb)
    ], (err, results) ->
      if err?
        console.error err
      else
        request.get {
          url: helpers.appurl("/indicators/#{indicator.id}.csv")
        }, (err, res, body) ->
          assert.equal res.statusCode, 200

          assert.strictEqual(
             body,
             expectedData,
             "Expected \n#{body} \nto equal \n #{expectedData}"
          )

          done()
  )
)
