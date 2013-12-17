assert = require('chai').assert
helpers = require '../helpers'
_ = require('underscore')
async = require('async')
Q = require('q')
sinon = require('sinon')

User = require('../../models/user.coffee').model
Narrative = require('../../models/narrative.coffee').model
Visualisation = require('../../models/visualisation.coffee').model
Indicator = require('../../models/indicator.coffee').model
Section = require('../../models/section.coffee').model
Page = require('../../models/page').model
HeadlineService = require('../../lib/services/headline')

suite('Page')
test('.create', (done) ->

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

  helpers.createSection(indicator: undefined, (err, section) ->
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

test('.getParent returns the page parent', (done) ->
  theIndicator = null
  Q.nfcall(helpers.createIndicator)
  .then((indicator)->
    theIndicator = indicator
    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
    )
  ).then((page) ->
    page.getParent()
  ).then((parent) ->
    assert.strictEqual parent.id, theIndicator.id
    done()
  ).fail(done)
)

test('.getOwnable returns the page parent', (done) ->
  theIndicator = null
  Q.nfcall(helpers.createIndicator)
  .then((indicator)->
    theIndicator = indicator
    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
    )
  ).then((page) ->
    page.getOwnable()
  ).then((owner) ->
    assert.strictEqual owner.id, theIndicator.id
    done()
  ).fail(done)
)

test('.canBeEditedBy given a user that is logged in it resolves', (done) ->
  theUser = theIndicator = thePage = null
  helpers.createUser().then((user) ->

    theUser = user
    Q.nfcall(
      helpers.createIndicator,
    )

  ).then((indicator) ->

    theIndicator = indicator
    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
    )

  ).then((page) ->
    thePage = page

    page.canBeEditedBy(theUser)
  ).then(->
    done()
  ).fail(done)
)

test('.canBeEditedBy when a user is not logged in fails with an appropriate error', (done) ->
  theOwner = theIndicator = thePage = null
  helpers.createUser().then((user) ->

    theOwner = user
    Q.nfcall(
      helpers.createIndicator,
      owner: theOwner
    )

  ).then((indicator) ->

    theIndicator = indicator
    helpers.createPage(
      parent_id: indicator._id
      parent_type: "Indicator"
    )

  ).then((page) ->

    thePage = page
    page.canBeEditedBy().then(->
      done(new Error("Expected canBeEditedBy to fail"))
    ).fail( (err) ->
      assert.strictEqual err.message, "Must be authenticated as a user to edit pages"
      done()
    )

  ).fail(done)
)

test('.createDraftClone clones a public page,
  duplicates the page attributes
  and sets is_draft to true', (done) ->

  publicPage = null
  Q.nfcall(
    helpers.createIndicator
  ).then( (indicator) ->
    helpers.createPage(
      title: "Lovely Page"
      parent_id: indicator.id
      parent_type: "Indicator"
    )
  ).then( (page) ->
    publicPage = page

    publicPage.createDraftClone()
  ).then( (clonedPage) ->

    assert.strictEqual clonedPage.title, publicPage.title
    assert.isTrue clonedPage.is_draft

    done()
  ).fail(done)
)

test('.createDraftClone clones a public page,
  and duplicates child sections with new IDs', (done) ->
  originalSection = null

  Q.nfcall(
    helpers.createIndicator
  ).then( (indicator) ->

    helpers.createPage(
      title: "Lovely Page"
      parent_id: indicator.id
      parent_type: "Indicator"
      sections: [
        title: "Lovely Section"
      ]
    )
  ).then( (page) ->
    originalSection = page.sections[0]

    page.createDraftClone()
  ).then( (clonedPage) ->

    assert.lengthOf clonedPage.sections, 1,
      "cloned page was expected to 1 cloned section, but has #{clonedPage.sections.length}"

    clonedSection = clonedPage.sections[0]

    assert.strictEqual clonedSection.title, originalSection.title,
      "Expected clonedSection.title (#{clonedSection.title}) to equal
        originalSection.title (#{originalSection.title})"

    assert.notEqual clonedSection.id.toString(), originalSection.id.toString(),
      "Expected clonedSection (id: #{clonedSection.id}) to be a new record, but had same id
        as originalSection (#{originalSection.id})"

    Q.nsend(
      Page, 'findFatModel', clonedPage.id,
    )
  ).then( (reloadedPage) ->
    reloadedSection = reloadedPage.sections[0]

    try
      assert.notEqual reloadedSection._id.toString(), originalSection._id.toString(),
        "Expected reloadedSection (id: #{reloadedSection._id}) to have a different
        id, but had same id as originalSection (#{originalSection.id})"

      done()
    catch err
      console.dir err
      done(new Error(err.message))

  ).fail(done)
)

test('.createDraftClone clones a public page,
  and duplicates child narratives', (done) ->
  publicPage = originalNarrative = null

  Q.nfcall(
    helpers.createIndicator
  ).then( (indicator) ->
    helpers.createPage(
      title: "Lovely Page"
      parent_id: indicator.id
      parent_type: "Indicator"
      sections: [
        title: "Lovely Section"
      ]
    )
  ).then( (page) ->
    publicPage = page

    section = publicPage.sections[0]
    Q.nfcall(
      helpers.createNarrative, {
        content: "Nested Narrative"
        section: section.id
      }
    )

  ).then( (narrative) ->
    originalNarrative = narrative

    publicPage.createDraftClone()
  ).then( (clonedPage) ->

    clonedSection = clonedPage.sections[0]

    Q.nsend(
      Narrative.findOne(section: clonedSection.id), 'exec'
    )

  ).then( (clonedNarrative) ->
    assert.isNotNull clonedNarrative, "Couldn't find a cloned narrative"

    assert.strictEqual clonedNarrative.title, originalNarrative.title,
      "Expected clonedNarrative.title (#{clonedNarrative.title}) to equal
        originalNarrative.title (#{originalNarrative.title})"

    assert.notStrictEqual clonedNarrative.id, originalNarrative.id,
      "Expected clonedNarrative.id (#{clonedNarrative.id}) to be different to
        originalNarrative.id (#{originalNarrative.id})"

    done()
  ).fail( done)
)

test('.createDraftClone clones a public page,
  and duplicates child visualisations', (done) ->
  publicPage = originalVisualisation = null

  Q.nfcall(
    helpers.createIndicator
  ).then( (indicator) ->
    helpers.createPage(
      title: "Lovely Page"
      parent_id: indicator.id
      parent_type: "Indicator"
      sections: [
        title: "Lovely Section"
      ]
    )
  ).then( (page) ->
    publicPage = page

    section = publicPage.sections[0]
    Q.nfcall(
      helpers.createVisualisation, {
        type: "Map"
        section: section.id
      }
    )

  ).then( (visualisation) ->
    originalVisualisation = visualisation

    publicPage.createDraftClone()
  ).then( (clonedPage) ->

    clonedSection = clonedPage.sections[0]

    Q.nsend(
      Visualisation.findOne(section: clonedSection.id), 'exec'
    )

  ).then( (clonedVisualisation) ->
    assert.isNotNull clonedVisualisation, "Couldn't find a cloned visualisation"

    assert.strictEqual clonedVisualisation.map, originalVisualisation.map,
      "Expected clonedVisualisation.map (#{clonedVisualisation.map}) to equal
        originalVisualisation.map (#{originalVisualisation.map})"

    assert.notStrictEqual clonedVisualisation.id, originalVisualisation.id,
      "Expected clonedVisualisation.id (#{clonedVisualisation.id}) to be different to
        originalVisualisation.id (#{originalVisualisation.id})"

    done()
  ).fail( done)
)

test(".giveSectionsNewIds on a page with one section
  gives that section a new ID
  and returns an array containing the section and it's original ID", (done) ->
  originalSectionId = null

  Q.nfcall(
    helpers.createIndicator
  ).then( (indicator) ->
    helpers.createPage(
      title: "Lovely Page"
      parent_id: indicator.id
      parent_type: "Indicator"
      sections: [
        title: "Lovely Section"
      ]
    )
  ).then( (page) ->
    originalSectionId = page.sections[0].id

    assert.ok originalSectionId, "Created Section was expected to have an id"

    page.giveSectionsNewIds()

  ).then( (sectionsAndOriginalIds) ->

    assert.lengthOf sectionsAndOriginalIds, 1, "Expected list of sections to have one section"

    sectionWithNewId = sectionsAndOriginalIds[0].section
    originalId = sectionsAndOriginalIds[0].originalId

    assert.strictEqual sectionWithNewId.constructor.name, "EmbeddedDocument",
      "Expected returned section to be mongo instance"

    assert.notStrictEqual sectionWithNewId.id, originalSectionId,
      "Expected section to have a new ID, but it's the same as the originalSectionId"
    assert.strictEqual originalId, originalSectionId,
      "Expected the returned originalId to be the same as the original section id"

    done()

  ).fail(done)
)

test(".setHeadlineToMostRecentFromParent when the parent is an indicator
  sets the headline to the indicator's most recent headline", (done) ->
  indicator = new Indicator()

  headlineTitle = 'Good'
  newestHeadlineStub = sinon.stub(HeadlineService::, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {text: headlineTitle}
    return deferred.promise
  )

  page = new Page(parent_type: 'Indicator')
  sinon.stub(page, 'getParent', ->
    deferred = Q.defer()
    deferred.resolve indicator
    return deferred.promise
  )

  page.setHeadlineToMostRecentFromParent().then(->
    assert.strictEqual page.headline.text, headlineTitle
    newestHeadlineStub.restore()
    done()
  ).fail(->
    newestHeadlineStub.restore()
    done()
  )
)

test(".setHeadlineToMostRecentFromParent when the parent is not an indicator
  doesn't modify the page headline attribute", (done) ->
  page = new Page(parent_type: 'Theme')

  page.setHeadlineToMostRecentFromParent().then(->
    assert.isUndefined page.headline, "Expected the page headline not to be modified"
    done()
  ).fail(done)
)

test("When no headline is set,
  setHeadlineToMostRecentFromParent should be called on save", (done)->
  page = new Page()
  newHeadline = text: 'hat'
  sinon.stub(page, 'setHeadlineToMostRecentFromParent', ->
    deferred = Q.defer()
    @headline =  newHeadline
    deferred.resolve newHeadline
    return deferred.promise
  )

  Q.nsend(
    page, 'save'
  ).then(->
    assert.strictEqual page.headline, newHeadline
    done()
  ).fail(done)
)

test('.setHeadlineToMostRecentFromParent when parent indicator has no
  data, sets headline text to "Not reported on"', (done) ->
  indicator = new Indicator()
  sinon.stub(indicator, 'getIndicatorData', (callback) ->
    callback(null, [])
  )

  page = new Page(parent_type: 'Indicator')
  sinon.stub(page, 'getParent', ->
    deferred = Q.defer()
    deferred.resolve indicator
    return deferred.promise
  )

  page.setHeadlineToMostRecentFromParent().then( (headline) ->
    assert.strictEqual(
      headline.text,
      "Not reported on",
      "Expected headline text to be 'Not report on'"
    )

    assert.strictEqual(
      headline.value,
      "-",
      "Expected headline value to be -"
    )

    assert.isNull(headline.periodEnd)

    done()
  ).fail( done)
)
