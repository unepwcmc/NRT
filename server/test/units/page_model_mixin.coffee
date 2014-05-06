assert = require('chai').assert
async = require('async')
_ = require('underscore')
Q = require('q')
sinon = require('sinon')

helpers = require('../helpers')
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
Section = require('../../models/section').model
Theme = require('../../models/theme').model
Page = require('../../models/page').model

suite('Page Model Mixin')

test(".getPage returns a mongoose instance", (done) ->
  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    indicator.getPage()
  ).then( (page) ->
    assert.strictEqual page.constructor.modelName, "Page", "Expected page to be a mongoose object"
    done()
  ).fail(done)
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

  ).fail(done)
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

    theIndicator.publishDraftPage()
  ).then( (page) ->
    publishedPage = page

    assert.strictEqual(
      publishedPage.parent_id.toString(), theIndicator.id,
      "Expected publishedPage.parent_id #{draftPage.parent_id} to be the _id of the
      parent indicator (#{theIndicator.id})"
    )
    assert.strictEqual publishedPage.parent_type, "Indicator"

    assert.isFalse publishedPage.is_draft, "Expected is_draft to be false for publishedPage"

    assert.strictEqual(
      publishedPage.title,
      nonDraftPage.title,
      "Expected published page title to be the same as the original"
    )

    Q.nsend(
      Page.find(parent_id: theIndicator.id), 'exec'
    )

  ).then( (foundPages) ->

    assert.lengthOf foundPages, 1, "Expected only one Page to exist after publishing"

    done()

  ).fail(done)
)

test(".deleteAllPagesExcept deletes all pages except the one passed in", (done) ->
  theIndicator = null
  thePages = []

  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    theIndicator = indicator

    helpers.createPage(
      parent_id: theIndicator.id
      parent_type: "Indicator"
      title: "Sup Bro"
    )

  ).then( (page) ->
    thePages.push(page)

    helpers.createPage(
      parent_id: theIndicator.id
      parent_type: "Indicator"
      title: "Sup Bro"
    )

  ).then( (page) ->
    thePages.push(page)

    theIndicator.deleteAllPagesExcept(thePages[0].id)
  ).then( ->

    Q.nsend(
      Page.find(parent_id: theIndicator.id), 'exec'
    )

  ).then( (foundPages) ->

    assert.lengthOf foundPages, 1, "Expected one page to remain after deletion"

    done()

  ).fail(done)
)

test(".discardDraft discards the draft version of a page", (done) ->
  theIndicator = null
  thePages = []

  Q.nfcall(
    helpers.createIndicator, {}
  ).then( (indicator) ->
    theIndicator = indicator

    helpers.createPage(
      parent_id: theIndicator.id
      parent_type: "Indicator"
      is_draft: false
      title: "Sup Bro"
    )

  ).then( (page) ->
    thePages.push(page)

    helpers.createPage(
      parent_id: theIndicator.id
      parent_type: "Indicator"
      is_draft: true
      title: "Sup Bro"
    )

  ).then( (page) ->
    thePages.push(page)

    theIndicator.discardDraft()
  ).then( ->

    Q.nsend(
      Page.find(parent_id: theIndicator.id), 'exec'
    )

  ).then( (foundPages) ->

    assert.lengthOf foundPages, 1, "Expected one page to remain after discarding drafts"
    assert.strictEqual(
      foundPages[0].id,
      thePages[0].id
    )

    done()

  ).fail(done)
)

test('.populatePage should add a (shallow) page attribute to an indicator', (done)->
  indicator = new Indicator()
  page = new Page()
  sinon.stub(indicator, 'getPage', ->
    deferred = Q.defer()
    deferred.resolve(page)
    return deferred.promise
  )

  indicator.populatePage().then(->

    assert.property indicator, 'page',
      "Expected the indicator to have a page attribute"
    assert.strictEqual indicator.page._id, page._id,
      "Expected the populated indicator page attribute to have the same ID as the page"
    assert.strictEqual indicator.page.constructor.modelName, "Page",
      "Expected the populated indicator page attribute to be an instance of the page model"
    done()

  ).fail((err) ->
    console.error err
    throw err
  )

)

test('.populatePage if the page attribute is already populated, should do nothing', (done)->
  indicator = new Indicator()
  page = new Page()
  indicator.page = page
  getPageStub = sinon.stub(indicator, 'getPage', ->
    deferred = Q.defer()
    deferred.resolve(page)
    return deferred.promise
  )

  indicator.populatePage().then(->

    assert.property indicator, 'page',
      "Expected the indicator to have a page attribute"
    assert.strictEqual indicator.page._id, page._id,
      "Expected the populated indicator page attribute to have the same ID as the page"
    assert.strictEqual getPageStub.callCount, 0,
      "Expected the getPage method not to be called, as the page attribute was already populated"
    done()

  ).fail((err) ->
    console.error err
    throw err
  )

)

test(".populateDescriptionFromPage on a model where the page model is populated,
  and it has a section with the title 'description',
  sets @description to that section's narrative", (done)->
  descriptionSection = null
  descriptionText = "My name is my name"
  theme = new Theme()

  Q.nfcall(
    Section.createSectionWithNarrative,
      title: "Description"
      content: descriptionText
  ).then( (section) ->
    descriptionSection = section

    theme.page = new Page(
      sections: [descriptionSection]
    )

    theme.populateDescriptionFromPage()
  ).then( ->

    assert.property theme, 'description', "Expected the description to be populated"
    assert.strictEqual theme.description, descriptionText,
      "Expected the description text to be populated correctly"

    done()

  ).fail( (err) ->
    console.error err
    throw err
  )
)

test(".populateDescriptionFromPage on a model where the page model isn't populated,
  gets the page, and gets @description from the page", (done)->
  descriptionSection = null
  descriptionText = "My name is my name"
  theme = new Theme()

  Q.nfcall(
    Section.createSectionWithNarrative,
      title: "Description"
      content: descriptionText
  ).then( (section) ->
    descriptionSection = section

    sinon.stub(theme, 'getPage', ->
      Q.fcall(->
        return new Page(
          sections: [descriptionSection]
        )
      )
    )

    theme.populateDescriptionFromPage()
  ).then( ->

    assert.property theme, 'description', "Expected the description to be populated"
    assert.strictEqual theme.description, descriptionText,
      "Expected the description text to be populated correctly"

    done()

  ).fail( (err) ->
    console.error err
    throw err
  )
)

test(".populateDescriptionFromPage on a model with no sections
  sets @description to an empty string", (done)->
  theme = new Theme()

  theme.page = new Page(
    sections: [title: 'Description']
  )

  theme.populateDescriptionFromPage().then( ->

    assert.property theme, 'description', "Expected the description to be populated"
    assert.strictEqual theme.description, '',
      "Expected the description text to be an empty string"

    done()

  ).fail( (err) ->
    console.error err
    throw err
  )
)

test(".populateDescriptionFromPage on a model with a description section with no narrative
  sets @description to an empty string", (done)->
  theme = new Theme()

  sinon.stub(theme, 'getPage', ->
    Q.fcall(->
      return new Page(
        sections: []
      )
    )
  )

  theme.populateDescriptionFromPage().then( ->

    assert.property theme, 'description', "Expected the description to be populated"
    assert.strictEqual theme.description, '',
      "Expected the description text to be an empty string"

    done()

  ).fail( (err) ->
    console.error err
    throw err
  )
)

test("#populateDescriptionsFromPages calls populateDescriptionFromPage
  on each given page", (done) ->
  indicator = new Indicator()
  populateStub = sinon.stub(indicator, 'populateDescriptionFromPage', ->
    Q.fcall(->
      indicator.description = "A description"
    )
  )

  Indicator.populateDescriptionsFromPages([indicator]).then( ->
    assert.strictEqual populateStub.callCount, 1,
      "Expected the indictor's populateDescriptionFromPage to be called once"
    assert.property indicator, 'description', "Expected indicator.description to be populated"

    done()
  ).fail((err) ->
    console.error err
    throw err
  )

)
