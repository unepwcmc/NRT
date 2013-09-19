suite('ThemeView')

test('given a theme with sections, it renders a section subview', ->
  theme = Factory.theme()
  theme.set('sections', [Factory.section()])
  themeView = new Backbone.Views.ThemeView(theme: theme)

  Helpers.renderViewToTestContainer(themeView)

  Helpers.viewHasSubViewOfClass(themeView, 'SectionView')
)

test(".addSection adds a section to the theme", ->
  theme = Factory.theme()
  themeView = new Backbone.Views.ThemeView(theme: theme)

  assert.lengthOf theme.get('sections'), 0

  themeView.addSection()

  assert.lengthOf theme.get('sections'), 1
  assert.strictEqual theme.get('sections').at(0).get('parent').get('cid'), theme.get('cid')
  assert.equal theme.get('sections').at(0).get('type'), "Section"
)
