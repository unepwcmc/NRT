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
      sections: [section]

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
        assert.strictEqual section._id, report.sections[0]._id
        callback()

      async.parallel([
        assertSectionCreated,
        assertReportHasSection
      ], done)
)

test('get "fat" report by report ID', (done) ->
  Report = require('../../models/report.coffee').model

  helpers.createIndicator( (err, indicator) ->
    helpers.createSection({
      title: 'A section',
      indicators: [indicator]
    }, (err, section) ->
      helpers.createVisualisation(
        {section_id: section._id},
        (err, visualisation) ->

          helpers.createNarrative(
            {section_id: section._id}
            (err, narrative) ->
              helpers.createReport( {sections: [section]}, (report) ->
                Report.findFatReport(report._id, (err, fatReport) ->
                  assert.equal fatReport._id, report.id

                  reloadedSection = fatReport.sections[0]
                  assert.equal reloadedSection._id, section.id

                  assert.property reloadedSection, 'indicators'
                  assert.equal indicator._id.toString(),
                    reloadedSection.indicators[0]._id.toString()

                  assert.property reloadedSection, 'visualisation'
                  assert.equal visualisation._id.toString(),
                    reloadedSection.visualisation._id.toString()

                  assert.property reloadedSection, 'narrative'
                  assert.equal narrative._id.toString(),
                    reloadedSection.narrative._id.toString()

                  done()
                )
              )
          )
      )
    )
  )
)
