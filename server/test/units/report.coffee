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
    introduction: 'We postulate that this report is lovely, and will
      prove it cyclically by filling the report with some lovely
      visualisations.'
    conclusion: 'This report is lovely afterall.'

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
  Section = require('../../models/section').model

  section = new Section(title: "A section")
  section.save (err, section) ->
    if err?
      throw 'Report saving failed'

    report_attributes =
      title: 'Lovely Report'
      brief: 'Gotta be brief'
      introduction: 'We postulate that this report is lovely, and will
        prove it cyclically by filling the report with some lovely
        visualisations.'
      conclusion: 'This report is lovely afterall.'
      sections: section

    report = new Report(report_attributes)
    report.save (err, report) ->
      if err?
        throw 'Report saving failed'

      assertSectionCreated = (callback) ->
        Section.count (err, count) ->
          if err?
            throw err
            throw 'Failed to find Section'

          assert.equal 1, count
          callback()

      assertReportHasSection = (callback) ->
        assert.equal section._id, report.sections[0]
        callback()

      async.parallel([
        assertSectionCreated,
        assertReportHasSection
      ], done)
)

test('update a nested section')
