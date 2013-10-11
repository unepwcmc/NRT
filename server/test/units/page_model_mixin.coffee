assert = require('chai').assert
helpers = require '../helpers'
Indicator = require('../../models/indicator').model
Section = require('../../models/section').model
Page = require('../../models/page').model
IndicatorData = require('../../models/indicator_data').model
async = require('async')
_ = require('underscore')
Q = require('q')

suite('Page Model Mixin')

test(".getPage returns a mongoose instance", (done) ->
  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    indicator.getPage()
  ).then( (page) ->
    assert.strictEqual page.constructor.modelName, "Page", "Expected page to be a mongoose object"
    done()
  ).fail( (err) ->
    console.error err
    throw err
  )
)

test(".getPage when no public page is associated creates a new page with is_draft false", (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    if err?
      console.error err
      throw err

    indicator.getPage().then((page)->
      assert.strictEqual(
        page.parent_id, indicator._id,
        "Expected page.parent_id #{page.parent_id} to be the _id of the
        parent indicator (#{indicator._id})"
      )
      assert.strictEqual page.parent_type, "Indicator"

      assert.isFalse page.is_draft

      Page.findOne(page._id).exec((err, foundPage) ->
        if err?
          console.error err
          throw err

        assert.strictEqual foundPage.id, page.id
        done()
      )
    ).done()
)

test('.getPage when a non-draft page is associated should get the page', (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    thePage = null

    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
      is_draft: false
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

test('.getFatPage returns fat pages', (done) ->
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

        indicator.getFatPage().done((foundPage) ->
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

test(".toObjectWithNestedPage returns an object representation of the
  indicator with its fat page attribute", (done) ->
  helpers.createIndicator {}, (err, indicator) ->
    thePage = null

    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
      is_draft: false
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

test(".getDraftPage
  when no draft page is associated
  and a non-draft page is associated
  it creates a clones of the non-draft and returns it", (done) ->

  theIndicator = nonDraftPage = draftPage = null

  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    theIndicator = indicator

    helpers.createPage(
      parent_id: indicator.id
      parent_type: "Indicator"
      is_draft: false
      title: "Sup Bro"
    )

  ).then( (page) ->
    nonDraftPage = page

    theIndicator.getDraftPage()

  ).then((page)->
    draftPage = page

    assert.strictEqual(
      draftPage.parent_id.toString(), theIndicator.id,
      "Expected draftPage.parent_id #{draftPage.parent_id} to be the _id of the
      parent indicator (#{theIndicator.id})"
    )
    assert.strictEqual draftPage.parent_type, "Indicator"

    assert.isTrue draftPage.is_draft

    # Confirm it's clone the public
    assert.strictEqual draftPage.title, nonDraftPage.title

    Q.nsend(
      Page.findOne(_id: draftPage._id), 'exec'
    )

  ).then( (foundPage) ->

    assert.strictEqual(
      foundPage.id, draftPage._id.toString(),
      "Expected to find the same page when looking for _id #{draftPage._id}
        but found page with id #{foundPage.id}"
    )
    done()

  ).fail( (err) ->
    console.error err
    throw err
  )
)

test(".publishDraftPage sets the page's draft status to false and
  deletes the current published version", (done) ->

  theIndicator = nonDraftPage = draftPage = publishedPage = null

  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    theIndicator = indicator

    helpers.createPage(
      parent_id: indicator.id
      parent_type: "Indicator"
      is_draft: false
      title: "Sup Bro"
    )

  ).then( (page) ->
    nonDraftPage = page

    theIndicator.getDraftPage()

  ).then( (page)->
    draftPage = page

    draftPage.publishDraftPage()
  ).then( (page) ->
    publishedPage = page

    assert.strictEqual(
      publishedPage.parent_id.toString(), theIndicator.id,
      "Expected publishedPage.parent_id #{draftPage.parent_id} to be the _id of the
      parent indicator (#{theIndicator.id})"
    )
    assert.strictEqual pubsliehdPage.parent_type, "Indicator"

    assert.isFalse publishedPage.is_draft, "Expected is_draft to be false for publishedPage"

    # Confirm it's clone the public
    assert.strictEqual publishedPage.title, nonDraftPage.title

    Q.nsend(
      Page.findOne(_id: draftPage._id), 'exec'
    )

  ).then( (foundPage) ->

    assert.strictEqual(
      foundPage.id, draftPage._id.toString(),
      "Expected to find the same page when looking for _id #{draftPage._id}
        but found page with id #{foundPage.id}"
    )
    done()

  ).fail( (err) ->
    console.error err
    throw err
  )
)

