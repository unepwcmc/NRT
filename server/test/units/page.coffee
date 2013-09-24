assert = require('chai').assert
helpers = require '../helpers'
_ = require('underscore')
async = require('async')

suite('Page')
test('.create', (done) ->
  Page = require('../../models/page').model

  page_attributes =
    title: 'Lovely Page'
    brief: 'Gotta be brief'

  page = new Page(page_attributes)
  page.save (err, page) ->
    if err?
      throw 'Page saving failed'

    Page.count (err, count) ->
      if err?
        throw err
        throw 'Failed to find Pages'

      assert.equal count, 1
      done()
)

test('.create with nested section', (done) ->
  Page = require('../../models/page').model

  page_attributes =
    title: 'Lovely Page'
    brief: 'Gotta be brief'
    sections: [{
      title: 'dat title'
    }]
  page = new Page(page_attributes)
  page.save((err, page) ->
    if err?
      console.error err
      throw 'Page saving failed'
      done()

    assert.strictEqual page.title, page_attributes.title
    assert.strictEqual page.sections[0].title, page_attributes.sections[0].title
    done()
  )
)

test('get "fat" page with all related children by page ID', (done) ->
  Page = require('../../models/page.coffee').model

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
              helpers.createPage( {sections: [section]}).then((page) ->
                Page.findFatModel(page._id, (err, fatPage) ->
                  assert.equal fatPage._id, page.id

                  reloadedSection = fatPage.sections[0]
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
              ).fail((err) ->
                console.error err
                throw err
              )
          )
      )
    )
  )
)

test('get "fat" page with no related children by page ID', (done) ->
  Page = require('../../models/page.coffee').model

  helpers.createSection((err, section) ->
    helpers.createPage({sections: [section]}).then(
      (page) ->
        Page.findFatModel(page._id, (err, fatPage) ->
          assert.equal fatPage._id, page.id

          reloadedSection = fatPage.sections[0]
          assert.equal reloadedSection._id, section.id

          assert.notProperty reloadedSection, 'indicator'

          assert.notProperty reloadedSection, 'visualisation'

          assert.notProperty reloadedSection, 'narrative'

          done()
        )
    ).fail((err) ->
      console.error err
      throw err
    )
  )
)

test('saving a page with section attributes should assign that section an _id', (done) ->
  helpers.createPage(
    title: "New page"
    sections: [
      title: "New section"
    ]
  ).then( (page) ->

    assert.strictEqual(
      page.sections[0].title,
      "New section",
      "Expected #{page.sections[0]}'s title to be 'New Section'"
    )
    assert.property page.sections[0], '_id'
    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.create with nested section', (done) ->
  Page = require('../../models/page.coffee').model

  page_attributes =
    sections: [{
      title: 'dat title'
    }]

  page = new Page(page_attributes)
  page.save((err, page) ->
    if err?
      console.error err
      throw 'page saving failed'
      done()

    assert.strictEqual page.title, page_attributes.title
    assert.strictEqual page.sections[0].title, page_attributes.sections[0].title
    done()
  )
)
