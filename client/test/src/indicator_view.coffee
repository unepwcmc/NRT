suite('IndicatorView')

test('given an indicator with sections, it renders a section subview', ->
  indicator = Factory.indicator()
  indicator.set('sections', [Factory.section()])
  indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

  Helpers.renderViewToTestContainer(indicatorView)

  Helpers.viewHasSubViewOfClass(indicatorView, 'SectionView')
)

test(".addSection adds a section to the indicator", ->
  indicator = Factory.indicator()
  indicatorView = new Backbone.Views.IndicatorView(indicator: indicator)

  assert.lengthOf indicator.get('sections'), 0

  indicatorView.addSection()

  assert.lengthOf indicator.get('sections'), 1
  assert.strictEqual indicator.get('sections').at(0).get('parent').get('cid'), indicator.get('cid')
  assert.equal indicator.get('sections').at(0).get('type'), "Section"
)
