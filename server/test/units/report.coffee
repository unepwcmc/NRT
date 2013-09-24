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

test('.create with nested section', (done) ->
  Report = require('../../models/report').model

  report_attributes =
    title: 'Lovely Report'
    brief: 'Gotta be brief'
    sections: [{
      title: 'dat title'
    }]

  report = new Report(report_attributes)
  report.save((err, report) ->
    if err?
      console.error err
      throw 'Report saving failed'
      done()

    assert.strictEqual report.title, report_attributes.title
    assert.strictEqual report.sections[0].title, report_attributes.sections[0].title
    done()
  )
)

test('.populatePageAttribute when no page is associated should create a new page', (done) ->
  helpers.createReport {}, (err, indicator) ->
    if err?
      console.error err
      throw err

    indicator.populatePageAttribute().then((page) ->
      console.log page
      assert.property indicator, 'page'
      assert.strictEqual indicator.page.parent_id, indicator._id
      assert.strictEqual indicator.page.parent_type, "Report"
      done()
    ).fail((err) ->
      console.error err
      throw err
    )
    
)

test('.populatePageAttribute when a page is associated should get the page')
