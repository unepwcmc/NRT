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

test('get "fat" report with all related children by report ID', (done) ->
  Report = require('../../models/report.coffee').model

  helpers.createIndicator( (err, indicator) ->
    helpers.createSection({
      title: 'A section',
      indicator: indicator
    }, (err, section) ->
      helpers.createVisualisation(
        {section: section._id},
        (err, visualisation) ->

          helpers.createNarrative(
            {section: section._id}
            (err, narrative) ->
              helpers.createReport( {sections: [section]}, (report) ->
                Report.findFatModel(report._id, (err, fatReport) ->
                  assert.equal fatReport._id, report.id

                  reloadedSection = fatReport.sections[0]
                  assert.equal reloadedSection._id, section.id

                  assert.property reloadedSection, 'indicator'
                  assert.equal indicator._id.toString(),
                    reloadedSection.indicator._id.toString()

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

test('get "fat" report with no related children by report ID', (done) ->
  Report = require('../../models/report.coffee').model

  helpers.createSection((err, section) ->
    helpers.createReport( {sections: [section]}, (report) ->
      Report.findFatModel(report._id, (err, fatReport) ->
        assert.equal fatReport._id, report.id

        reloadedSection = fatReport.sections[0]
        assert.equal reloadedSection._id, section.id

        assert.notProperty reloadedSection, 'indicator'

        assert.notProperty reloadedSection, 'visualisation'

        assert.notProperty reloadedSection, 'narrative'

        done()
      )
    )
  )
)
