assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
Section = require('../../models/section').model
Page = require('../../models/page').model
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')

suite('Page Model Mixin')

test('.getPage when no page is associated should create a new page', (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    if err?
      console.error err
      throw err

    indicator.getPage().then((page)->
      assert.strictEqual page.parent_id, indicator._id
      assert.strictEqual page.parent_type, "Indicator"

      Page.findOne(page._id).exec((err, foundPage) ->
        if err?
          console.error err
          throw err

        assert.strictEqual foundPage.id, page.id
        done()
      )
    ).done()
)

test('.getPage when a page is associated should get the page', (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    thePage = null

    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
    ).then( (page)->
      thePage = page
      indicator.getPage()
    ).then( (fetchedPage) ->
      assert.strictEqual(
        fetchedPage._id.toString(),
        thePage._id.toString()
      )
      assert.strictEqual fetchedPage.parent_type, "Indicator"
      done()
    ).done()
)

test('.getPage returns fat pages', (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    theFatPage = null

    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
      sections: [new Section(
        title: 'hat'
        indicator: indicator._id
      )]
    ).done( (page)->
      Page.findFatModel(page._id, (err, theFatPage) ->
        if err?
          console.error err
          throw err

        indicator.getPage().done((foundPage) ->
          assert.ok(
            _.isEqual(theFatPage, foundPage),
            """
              Expected \n
              #{JSON.stringify(theFatPage)}\n
              to be equal to\n
              #{JSON.stringify(foundPage)}
            """
          )

          assert.property foundPage, 'sections'
          done()
        )
      )
    )
)

test(".toObjectWithNestedPage returns an object representation of the indicator with it's page attribute", (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    thePage = null

    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
    ).then( (page)->
      thePage = page
      indicator.toObjectWithNestedPage()
    ).done( (indicatorObject) ->
      assert.strictEqual(
        indicatorObject._id.toString(),
        indicator._id.toString()
      )

      page = indicatorObject.page
      assert.strictEqual(
        page._id.toString(),
        thePage._id.toString()
      )

      done()
    )
)
