assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

suite('API - Theme')

Theme = require('../../models/theme').model

test('POST create', (done) ->
  data =
    title: "new theme"

  request.post({
    url: helpers.appurl('api/themes/')
    json: true
    body: data
  },(err, res, body) ->
    if err?
      console.error err
      throw err
    id = body._id

    assert.equal res.statusCode, 201

    Theme
      .findOne(_id: id)
      .exec( (err, theme) ->
        if err?
          console.error err
          throw err
        assert.equal theme.title, data.title
        done()
      )
  )
)

test("GET show", (done) ->
  helpers.createTheme().then( (theme) ->
    request.get({
      url: helpers.appurl("api/themes/#{theme.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedTheme = body
      assert.equal reloadedTheme._id, theme.id
      assert.equal reloadedTheme.content, theme.content

      done()
    )
  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('GET index', (done) ->
  helpers.createThemesFromAttributes([{},{}]).then( (themes) ->
    request.get({
      url: helpers.appurl("api/themes")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      themeJson = body

      assert.equal themeJson.length, themes.length
      jsonTitles = _.map(themeJson, (theme)->
        theme.title
      )
      themeTitles = _.map(themes, (theme)->
        theme.title
      )

      assert.deepEqual jsonTitles, themeTitles
      done()
    )
  ).fail((err) ->
    console.error err
    throw new Error(err)
  )
)

test('DELETE theme', (done) ->
  helpers.createTheme().then( (theme) ->
    request.del({
      url: helpers.appurl("api/themes/#{theme.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Theme.count( (err, count)->
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

test('PUT theme', (done) ->
  helpers.createTheme().then( (theme) ->
    new_title = "Updated title"
    section_title = "OHAI little brother"
    request.put({
      url: helpers.appurl("/api/themes/#{theme.id}")
      json: true
      body:
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Theme
        .findOne(id)
        .exec( (err, theme) ->
          assert.equal theme.title, new_title

          done()
        )
    )
  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('PUT theme does not fail when an _id is given', (done) ->
  helpers.createTheme().then( (theme) ->
    new_title = "Updated title"
    request.put({
      url: helpers.appurl("/api/themes/#{theme.id}")
      json: true
      body:
        _id: theme.id
        title: new_title
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Theme
        .findOne(id)
        .exec( (err, theme) ->
          assert.equal theme.title, new_title
          done()
        )
    )
  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('GET theme/:id with nested sections returns sections', (done) ->
  helpers.createSection( {title: "A title"}, (err, section) ->
    theTheme = null
    helpers.createTheme().
      then( (theme) ->
        theTheme = theme
        console.log 'the test'
        console.log theTheme._id
        helpers.createPage(
          parent_id: theme._id
          parent_type: "Theme"
          sections: [section]
        )).
      then( (page) ->
        request.get({
          url: helpers.appurl("api/themes/#{theTheme.id}")
          json: true
        }, (err, res, body) ->
          assert.equal res.statusCode, 200

          returnedTheme = body
          assert.equal returnedTheme._id, theTheme.id
          assert.equal returnedTheme.content, theTheme.content

          assert.property returnedTheme, 'page'
          returnedPage = returnedTheme.page

          assert.equal page._id, returnedPage._id

          assert.property returnedPage, 'sections'

          assert.property returnedTheme, 'sections'
          assert.lengthOf returnedTheme.sections, 1

          done()
        )
      ).fail( (err) ->
        console.error err
        throw new Error(err)
      )
  )
)
