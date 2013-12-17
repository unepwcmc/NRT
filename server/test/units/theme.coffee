assert = require('chai').assert
helpers = require '../helpers'
Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
async = require('async')
Q = require('q')
_ = require('underscore')

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
      title: "I'm an indicator of theme 1"
      theme: themes[0]._id
      type: "esri"
    },{
      title: "theme 2 indicator"
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
      }, ->
        callback()
      )

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

    assert.strictEqual returnedThemes[0].indicators[0].title, indicatorAttributes[0].title
    assert.strictEqual returnedThemes[1].indicators[0].title, indicatorAttributes[1].title

    assert.property returnedThemes[0].indicators[0], 'page',
      "Expected indicators to have their page attribute populated"

    assert.property returnedThemes[0].indicators[0], 'narrativeRecency',
      "Expected indicators to have their narrative recency attribute calculated"

    done()
  ).fail(done)
)

test('#getFetThemes only returns themes with indicators of type ESRI', (done) ->
  helpers.createThemesFromAttributes(
    [{title: 'a theme'}]
  ).then((themes) ->
    indicatorAttributes = [{
      title: "ESRI indicator"
      theme: themes[0]._id
      type: "esri"
    },{
      title: "world bank indicator"
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
      }, ->
        callback()
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
  ).fail(done)
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
      title: "I'm an indicator of theme 1"
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

      assert.strictEqual returnedIndicators[0].title, indicatorAttributes[0].title
      done()
    )
  ).fail(done)
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
      title: "I'm an indicator of theme 1"
      theme: themes[0]._id
      dpsir: pressure: true
    }, {
      title: "I'm also an indicator of theme 1"
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

      assert.strictEqual indicators[0].title, indicatorAttributes[1].title

      done()
    catch err
      done(err)
  ).fail(done)
)

test('.getIndicators returns all Indicators for given Theme', (done) ->
  themeAttributes = [{
    title: 'Theme 1'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) ->
    indicatorAttributes = [{
      title: "I'm an indicator of theme 1"
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
        assert.strictEqual returnedIndicators[0].title, indicatorAttributes[0].title

        done()
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
  ).fail( (err) ->
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
