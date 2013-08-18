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
        assert.equal section._id, report.sections[0]
        callback()

      async.parallel([
        assertSectionCreated,
        assertReportHasSection
      ], done)
)

test('get "fat" report by report ID', (done) ->
  Report = require('../../models/report.coffee').model

  createSectionWithSubDocuments = (err, results) ->
    indicator = results[0]
    visualisation = results[1]
    narrative = results[2]

    helpers.createSection(
      {
        title: 'A section',
        indicator: indicator._id
        visualisation: visualisation._id
        narrative: narrative._id
      },
      (section) ->
        helpers.createReport( {sections: [section]}, (report) ->
          Report.findFatReport(report._id, (err, fatReport) ->
            assert.equal fatReport._id, report.id

            reloadedSection = fatReport.sections[0]
            assert.equal reloadedSection._id, section.id

            assert.property reloadedSection, 'indicator'
            assert.equal indicator._id, reloadedSection.indicator.id

            assert.property reloadedSection, 'visualisation'
            assert.equal visualisation._id, reloadedSection.visualisation.id

            assert.property reloadedSection, 'narrative'
            assert.equal narrative._id, reloadedSection.narrative.id

            done()
          )
        )
    )

  async.series([
    helpers.createIndicator,
    helpers.createVisualisation,
    helpers.createNarrative
  ], createSectionWithSubDocuments)
)
