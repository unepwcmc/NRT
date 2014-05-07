_ = require('underscore')
assert = require('chai').assert
async = require('async')
Q = require('q')
sinon = require('sinon')

helpers = require('../helpers')
Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model

suite('Theme')

test('.getFatThemes returns all the themes
  with their indicators that have data populated
  and their sub pages populated', (done) ->
  indicatorAttributes = null
  themeAttributes = [{
    title: 'Theme 1'
  },{
    title: 'Theme 2'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then((themes) ->
    indicatorAttributes = [{
      name: "I'm an indicator of theme 1"
      theme: themes[0]._id
      type: "esri"
    },{
      name: "theme 2 indicator"
      theme: themes[1]._id
      type: "esri"
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    )
  ).then( (subIndicators)->
    # create indicator data
    deferred = Q.defer()

    createIndicatorData = (indicator, callback) ->
      helpers.createIndicatorData({
        indicator: indicator
        data: [{data: 'yeah'}]
      }).then( (indicatorData) ->
        callback()
      ).catch(callback)

    async.each subIndicators, createIndicatorData, (err) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve()

    return deferred.promise
  ).then( ->
    Q.nfcall(
      Theme.getFatThemes
    )
  ).then( (returnedThemes) ->

    assert.lengthOf returnedThemes, 2

    assert.strictEqual returnedThemes[0].title, themeAttributes[0].title
    assert.strictEqual returnedThemes[1].title, themeAttributes[1].title

    assert.lengthOf returnedThemes[0].indicators, 1
    assert.lengthOf returnedThemes[1].indicators, 1

    assert.strictEqual returnedThemes[0].indicators[0].name, indicatorAttributes[0].name
    assert.strictEqual returnedThemes[1].indicators[0].name, indicatorAttributes[1].name

    assert.property returnedThemes[0].indicators[0], 'page',
      "Expected indicators to have their page attribute populated"

    assert.property returnedThemes[0].indicators[0], 'narrativeRecency',
      "Expected indicators to have their narrative recency attribute calculated"

    done()
  ).catch(done)
)

test('#getFetThemes only returns themes with indicators of type ESRI', (done) ->
  helpers.createThemesFromAttributes(
    [{title: 'a theme'}]
  ).then((themes) ->
    indicatorAttributes = [{
      name: "ESRI indicator"
      theme: themes[0]._id
      type: "esri"
    },{
      name: "world bank indicator"
      theme: themes[0]._id
      type: "worldbank"
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    )
  ).then( (subIndicators)->
    # create indicator data
    deferred = Q.defer()

    createIndicatorData = (indicator, callback) ->
      helpers.createIndicatorData({
        indicator: indicator
        data: [{data: 'yeah'}]
      }).then( (indicatorData) ->
        callback()
      ).catch( (err) ->
        callback(err)
      )

    async.each subIndicators, createIndicatorData, (err) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve()

    return deferred.promise
  ).then( ->
    Q.nsend(
      Theme, 'getFatThemes'
    )
  ).then( (fatThemes)->
    assert.lengthOf fatThemes, 1, "Only expected one theme to be returned"

    fatTheme = fatThemes[0]
    assert.lengthOf fatTheme.indicators, 1, "Only expected one indicator to be returned"

    assert.strictEqual fatTheme.indicators[0].type, "esri",
      "Expected the returned indicator to be an ESRI indicator"

    done()
  ).catch(done)
)

test('.getIndicatorsByTheme returns all Indicators for given Theme', (done) ->
  theThemes = indicatorAttributes = null

  themeAttributes = [{
    title: 'Theme 1'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) =>
    theThemes = themes

    indicatorAttributes = [{
      name: "I'm an indicator of theme 1"
      theme: themes[0]._id
      type: 'esri'
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    )
  ).then( (subIndicators)->
    Theme.getIndicatorsByTheme(theThemes[0]._id, (err, returnedIndicators) ->
      if err?
        console.error(err)
        throw new Error(err)

      assert.lengthOf returnedIndicators, 1

      assert.strictEqual returnedIndicators[0].name, indicatorAttributes[0].name
      done()
    )
  ).catch(done)
)

test('.getIndicatorsByTheme supports an optional filter object', (done) ->
  theThemes = indicatorAttributes = null

  themeAttributes = [{
    title: 'Theme 1'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) =>
    theThemes = themes

    indicatorAttributes = [{
      name: "I'm an indicator of theme 1"
      theme: themes[0]._id
      dpsir: pressure: true
    }, {
      name: "I'm also an indicator of theme 1"
      theme: themes[0]._id
      dpsir: state: true
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    )
  ).then( (indicators)->
    Q.nfcall(
      Theme.getIndicatorsByTheme, theThemes[0]._id, {"dpsir.state": true}
    )
  ).then( (indicators) ->
    try
      assert.lengthOf indicators, 1,
        "Expected 1 indicator to be returned"

      assert.strictEqual indicators[0].name, indicatorAttributes[1].name

      done()
    catch err
      done(err)
  ).catch(done)
)

test('.getIndicators returns all Indicators for given Theme', (done) ->
  themeAttributes = [{
    title: 'Theme 1'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) ->
    indicatorAttributes = [{
      name: "I'm an indicator of theme 1"
      theme: themes[0]._id
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    ).then( (subIndicators)->
      themes[0].getIndicators((err, returnedIndicators) ->
        if err
          console.error(err)
          throw new Error(err)

        assert.lengthOf returnedIndicators, 1
        assert.strictEqual returnedIndicators[0].name, indicatorAttributes[0].name

        done()
      )
    ).catch( (err) ->
      console.error err
      throw new Error(err)
    )
  ).catch( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('.getPage should be mixed in', ->
  theme = new Theme()
  assert.typeOf theme.getPage, 'Function'
)

test('.getFatPage should be mixed in', ->
  theme = new Theme()
  assert.typeOf theme.getFatPage, 'Function'
)

test(".toObjectWithNestedPage is mixed in", ->
  theme = new Theme()
  assert.typeOf theme.toObjectWithNestedPage, 'Function'
)

test("#seedData when no seed file exist reports an appropriate error", (done) ->
  fs = require('fs')
  readFileStub = sinon.stub(fs, 'readFileSync', ->
    throw new Error("ENOENT, no such file or directory './config/seeds/themes.json'")
  )

  Theme.seedData().then(->
    done("Expected Theme.seedData to fail")
  ).catch((err)->

    try
      console.log err
      assert.strictEqual(
        err,
        "Unable to load theme seed file, have you copied seeds from config/instances/ to config/seeds/?"
      )
      done()
    catch err
      done(err)

  ).finally(->
    readFileStub.restore()
  )
)

test('#findOrCreateByTitle when a theme exists with that title, returns
  the existing theme', (done) ->
  title = 'magic theme'
  helpers.createThemesFromAttributes(
    [{title: title}, {title: "Some rubbish"}]
  ).then((themes) ->
    theTheme = themes[0]

    Theme.findOrCreateByTitle(title).then( (theme)->
      try
        assert.strictEqual theme.id, theTheme.id,
          "Expected the existing theme to be returned"
        done()
      catch err
        done(err)
    )
  ).catch(done)
)

test("#findOrCreateByTitle when a theme doesn't exists, creates a
  new theme and returns it", (done) ->
  title = 'magic theme'
  nonExistingTitle = 'super theme'

  helpers.createThemesFromAttributes(
    [{title: title}, {title: "Some rubbish"}]
  ).then((themes) ->
    theTheme = themes[0]

    createThemeStub = sinon.stub(Theme, 'create', (attributes, cb) ->
      cb(null, new Theme(title: attributes.title))
    )

    Theme.findOrCreateByTitle(nonExistingTitle).then( (theme)->
      try
        assert.strictEqual createThemeStub.callCount, 1,
          "Expected Theme.create to be called once"

        assert.strictEqual theme.title, nonExistingTitle,
          "Expected the created theme to have the right title"
        done()
      catch err
        done(err)
    )
  ).catch(done)
)