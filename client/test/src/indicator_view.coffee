suite('IndicatorView')

test('given an indicator with sections, it renders a section subview', ->
  indicator = Factory.indicator()
  indicator.set('sections', [Factory.section()])
  indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

  Helpers.renderViewToTestContainer(indicatorView)

  Helpers.viewHasSubViewOfClass(indicatorView, 'SectionView')
)
