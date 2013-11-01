assert = chai.assert

suite('Section Collection')

test('.reorderByCid when given an array of CIDs reorders the collection', ->
  sections = new Backbone.Collections.SectionCollection([
    {title: 'Section 1'}, {title: 'Section 2'}, {title: 'Section 3'}
  ])

  cids = sections.map((section)->
    section.cid
  )
  reorderedCids = [cids[1], cids[2], cids[0]]

  sections.reorderByCid(reorderedCids)

  assert.strictEqual sections.at(0).get('title'), 'Section 2'
  assert.strictEqual sections.at(1).get('title'), 'Section 3'
  assert.strictEqual sections.at(2).get('title'), 'Section 1'
)
