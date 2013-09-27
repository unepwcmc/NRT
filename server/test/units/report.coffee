assert = require('chai').assert
helpers = require '../helpers'
_ = require('underscore')
async = require('async')

Report = require('../../models/report').model

suite('Report')
test('.create', (done) ->
  report_attributes =
    title: 'Lovely Report'
    brief: 'Gotta be brief'

  report = new Report(report_attributes)
  report.save (err, report) ->
    if err?
      throw 'Report saving failed'

    Report.count (err, count) ->
      if err?
        throw err
        throw 'Failed to find Reports'

      assert.equal 1, count
      done()
)

test('.getPage should be mixed in', ->
  report = new Report()
  assert.typeOf report.getPage, 'Function'
)

test(".toObjectWithNestedPage is mixed in", ->
  report = new Report()
  assert.typeOf report.toObjectWithNestedPage, 'Function'
)
