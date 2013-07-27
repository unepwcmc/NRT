assert = require('chai').assert
helpers = require '../helpers'
_ = require('underscore')


suite('Report')
test('.create', (done) ->
  Report = require '../../models/report'
  report_attributes =
    title: 'Lovely Report'
    brief: 'Gtta b brf n dis dscrption'
    introduction: 'We postulate that this report is lovely, and will
      prove it cyclically by filling the report with some lovely
      visualisations.'
    conclusion: 'This report is lovely afterall.'

  Report.create(report_attributes).success( ->
    Report.count().
      success((count)->
        assert.equal 1, count
        done()
      ).failure( (err) ->
        throw err
        throw 'Failed to find Reports'
      )
  ).
  failure( ->
    throw 'Report saving failed'
  )
)

test('.parseFatSQL', ->
  Report = require '../../models/report'
  actual = Report.parseFatSQL([
    {
      "title": "foo",
      "id": 1,
      "createdAt": "2013-07-26T08:27:53.000Z",
      "updatedAt": "2013-07-26T08:27:53.000Z",
      "Sections": {
        "title": "section one",
        "report_id": 1,
        "id": 1,
        "createdAt": "2013-07-26T08:45:19.000Z",
        "updatedAt": "2013-07-26T08:45:19.000Z"
      },
      "Narratives": {
        "section_id": 1,
        "content": "blah blah",
        "id": 1
      }
    },
    {
      "title": "foo",
      "id": 1,
      "createdAt": "2013-07-26T08:27:53.000Z",
      "updatedAt": "2013-07-26T08:27:53.000Z",
      "Sections": {
        "title": "section two",
        "report_id": 1,
        "id": 2,
        "createdAt": "2013-07-26T08:45:24.000Z",
        "updatedAt": "2013-07-26T08:45:24.000Z"
      },
      "Narratives": {
        "section_id": null,
        "content": null,
        "id": null
      }
    }
  ])
  expected = {
    "title": "foo"
    "id": 1
    "createdAt": "2013-07-26T08:27:53.000Z",
    "updatedAt": "2013-07-26T08:27:53.000Z",
    "sections": [
      {
        "title": "section one",
        "report_id": 1,
        "id": 1,
        "createdAt": "2013-07-26T08:45:19.000Z",
        "updatedAt": "2013-07-26T08:45:19.000Z",
        "narrative":
          "section_id": 1,
          "content": "blah blah",
          "id": 1
      },
      {
        "title": "section two",
        "report_id": 1,
        "id": 2,
        "createdAt": "2013-07-26T08:45:24.000Z",
        "updatedAt": "2013-07-26T08:45:24.000Z"
        "narrative": null
      }
    ]
  }
  assert _.isEqual(expected, actual),
    "Expected #{JSON.stringify(expected, null, 2)}
     to equal #{JSON.stringify(actual, null, 2)}"
)
