suite('IndicatorView')

test('given an indicator with a page with a section, it renders a section subview', ->
  page = Factory.page()
  page.set('sections', [Factory.section()])
  indicator = Factory.indicator(page: page)
  indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

  Helpers.renderViewToTestContainer(indicatorView)

  Helpers.viewHasSubViewOfClass(indicatorView, 'SectionView')

  indicatorView.close()
)

test(".addSection adds a section to the page on the indicator", ->
  page = Factory.page()
  indicator = Factory.indicator(page: page)
  indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

  assert.lengthOf page.get('sections'), 0

  indicatorView.addSection()

  assert.lengthOf page.get('sections'), 1
  assert.strictEqual(
    page.get('sections').at(0).get('page').get('cid'),
    page.get('cid')
  )

  assert.equal page.get('sections').at(0).get('type'), "Section"

  indicatorView.close()
)
