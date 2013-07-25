assert = require('chai').assert
helpers = require '../helpers'

Report = require '../../models/report'

suite('Report')
test('.create', ->
  report_attributes =
    title: 'Lovely Report'
    brief: 'Gtta b brf n dis dscrption'
    introduction: 'We postulate that this report is lovely, and will
      prove it cyclically by filling the report with some lovely
      visualisations.'
    conclusion: 'This report is lovely afterall.'

  Report.create(report_attributes).success( ->
    Report.findAndCountAll().
      success((count)->
        assert.equal 1, count
      ).
      failure( ->
        throw 'Report saving failed'
      )
  )
)
