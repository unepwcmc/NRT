suite('ThemeView')

test('given a theme with sections, it renders a section subview', ->
  page = Factory.page()
  page.set('sections', [Factory.section()])
  theme = Factory.theme(page: page)
  themeView = new Backbone.Views.ThemeView(theme: theme)

  Helpers.renderViewToTestContainer(themeView)

  Helpers.viewHasSubViewOfClass(themeView, 'SectionView')
)

test(".addSection adds a section to the theme", ->
  page = Factory.page()
  theme = Factory.theme(page: page)
  themeView = new Backbone.Views.ThemeView(theme: theme)

  assert.lengthOf page.get('sections'), 0

  themeView.addSection()

  assert.lengthOf page.get('sections'), 1
  assert.strictEqual(
    page.get('sections').at(0).get('page').get('cid'),
    page.get('cid')
  )

  assert.equal page.get('sections').at(0).get('type'), "Section"

  themeView.close()
)
