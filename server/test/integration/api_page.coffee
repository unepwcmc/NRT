assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')
passportStub = require 'passport-stub'
Q = require 'q'

suite('API - Page')

Page = require('../../models/page').model
Indicator = require('../../models/indicator').model
Visualisation = require('../../models/visualisation').model
Narrative = require('../../models/narrative').model
Section = require('../../models/section').model

test('GET show', (done) ->
  data =
    title: "new page"

  helpers.createPage().
    then( (page) ->
      request.get({
        url: helpers.appurl("api/pages/#{page.id}")
        json: true
      }, (err, res, body) ->
        assert.equal res.statusCode, 200

        reloadedPage = body
        assert.equal reloadedPage._id, page.id
        assert.equal reloadedPage.content, page.content

        done()
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)

test('GET index', (done) ->
  helpers.createPage().
    then( (page) ->
      request.get({
        url: helpers.appurl("api/pages")
        json: true
      }, (err, res, body) ->
        assert.equal res.statusCode, 200

        pages = body
        assert.equal pages[0]._id, page.id
        assert.equal pages[0].content, page.content

        done()
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)

test('DELETE page', (done) ->
  helpers.createPage().
    then( (page) ->
      request.del({
        url: helpers.appurl("api/pages/#{page.id}")
        json: true
      }, (err, res, body) ->
        assert.equal res.statusCode, 204

        Page.count( (err, count)->
          unless err?
            assert.equal 0, count
            done()
        )
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)

test('PUT page', (done) ->
  helpers.createPage().
    then( (page) ->
      new_title = "Updated title"
      request.put({
        url: helpers.appurl("/api/pages/#{page.id}")
        json: true
        body:
          title: new_title
      }, (err, res, body) ->

        assert.equal res.statusCode, 200

        Page.count( (err, count)->
          assert.equal count, 1
          Page
            .findOne(page.id)
            .exec( (err, page) ->
              assert.equal page.title, new_title
              done()
            )
        )
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)

test('PUT page succeeds with an _id sent', (done) ->
  helpers.createPage().
    then( (page) ->
      new_title = "Updated title"
      request.put({
        url: helpers.appurl("/api/pages/#{page.id}")
        json: true
        body:
          _id: page.id
          title: new_title
      }, (err, res, body) ->
        id = body.id

        assert.equal res.statusCode, 200

        Page
          .findOne(id)
          .exec( (err, page) ->
            assert.equal page.title, new_title
            done()
        )
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)

test('PUT page succeeds with an _id sent', (done) ->
  helpers.createPage().
    then( (page) ->
      new_title = "Updated title"
      request.put({
        url: helpers.appurl("/api/pages/#{page.id}")
        json: true
        body:
          _id: page.id
          title: new_title
      }, (err, res, body) ->
        id = body.id

        assert.equal res.statusCode, 200

        Page
          .findOne(id)
          .exec( (err, page) ->
            assert.equal page.title, new_title
            done()
          )
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)

test('PUT nesting a section in a page with existing sections', (done) ->
  createPageWithSection = (err, results) ->
    section = results[0]

    helpers.createPage(
      title: "A page"
      sections: [section]
    ).then( (page) ->
      updateAttributes = page.toObject()
      updateAttributes.sections.push {title: 'hi'}

      request.put({
        url: helpers.appurl("/api/pages/#{page.id}")
        json: true
        body: updateAttributes
      }, (err, res, body) ->
        assert.equal res.statusCode, 200
        assert.lengthOf body.sections, 2

        assert.property body.sections[1], '_id'

        done()
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )

  async.series([helpers.createSection, helpers.createSection], createPageWithSection)
)

test('POST create - nesting a section in a page when authenticated as the owner', (done) ->
  data = null

  helpers.createUser().then((user) ->

    # Login user and create indicator
    passportStub.login user

    Q.nfcall(
      helpers.createIndicator, {
        title: 'dat indicator'
        owner: user
      }
    )

  ).then( (indicator) ->

    # Post new page
    data =
      title: "new page"
      sections: [{
        title: 'new section'
        indicator: indicator._id
      }]

    Q.nfcall(
      request.post, {
        url: helpers.appurl('api/pages/')
        json: true
        body: data
      }
    )

  ).then( (res, body) ->

    # Assert expected outcomes
    id = body._id

    assert.equal res.statusCode, 201

    assert.property body, 'sections'
    assert.lengthOf body.sections, 1
    assert.isDefined body.sections[0]._id, "New page Section not assigned an ID"
    assert.equal body.sections[0].title, data.sections[0].title

    assert.equal body.sections[0].indicator.title, indicator.title

    Page
      .findOne(_id: id)
      .exec( (err, page) ->
        assert.equal page.title, data.title
        done()
      )

  ).fail((err) ->
    console.error err
    throw err
  )
)

test("PUT update when given a ID which doesn't exist throws an appropriate error", (done)->
  pageId = (new Page())._id
  request.put({
    url: helpers.appurl("api/pages/#{pageId}")
    json: true
    body: {}
  },(err, res, body) ->
    assert.equal res.statusCode, 404
    assert.equal res.body, "Couldn't find page #{pageId} to update"
    done()
  )
)
