assert = require('chai').assert
helpers = require '../helpers'
_ = require('underscore')
async = require('async')

suite('Report')
test('.create', (done) ->
  Report = require('../../models/report').model

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

test('.populatePageAttribute when no page is associated should create a new page', (done) ->
  helpers.createReport {}, (report) ->
    report.populatePageAttribute().then((page) ->
      assert.property report, 'page'
      assert.strictEqual report.page.parent_id, report._id
      assert.strictEqual report.page.parent_type, "Report"
      done()
    ).fail((err) ->
      console.error err
      throw err
    )
)

test('.populatePageAttribute when a page is associated should get the page', (done) ->
  helpers.createReport {}, (report) ->
    thePage = null

    helpers.createPage(
      parent_id: report._id
      parent_type: "Report"
    ).then( (page)->
      thePage = page
      report.populatePageAttribute()
    ).then( (populatedPage) ->
      assert.property report, 'page'
      assert.strictEqual(
        report.page._id.toString(),
        thePage._id.toString()
      )
      assert.strictEqual report.page.parent_type, "Report"
      done()
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)
