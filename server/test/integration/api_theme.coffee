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
        sections: [
          title: section_title
        ]
    }, (err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 200

      Theme
        .findOne(id)
        .exec( (err, theme) ->
          assert.equal theme.title, new_title

          assert.lengthOf theme.sections, 1
          assert.strictEqual theme.sections[0].title, section_title
          assert.property theme.sections[0], '_id'

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
    helpers.createTheme({sections: [section]}).then( (theme) ->
      request.get({
        url: helpers.appurl("api/themes/#{theme.id}")
        json: true
      }, (err, res, body) ->
        assert.equal res.statusCode, 200

        returnedTheme = body
        assert.equal returnedTheme._id, theme.id
        assert.equal returnedTheme.content, theme.content

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
