assert = require('chai').assert
helpers = require '../helpers'
Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
helpers = require '../helpers'
async = require('async')
Q = require('q')
_ = require('underscore')
sinon = require('sinon')

suite('Theme')

test('#getFatThemes returns all the themes
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
    },{
      title: "theme 2 indicator"
      theme: themes[1]._id
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
  ).fail((err)->
    console.error err
    console.error err.stack
    throw new Error(err)
  )
)

test('#getFatThemes when given filters a mongoose filter it filters the themes', (done) ->
  themeSpy = sinon.spy(Theme, 'find')

  filter = {type: 'esri'}

  Theme.getFatThemes(filter, (err)->
    if err?
      console.error err
      throw err

    assert.ok themeSpy.calledOnce, "Expected Theme.find to be called once"
    assert.ok themeSpy.calledWith(filter), "Expected Theme.find to be called with the filter"
    done()
  )
)

test('.getIndicatorsByTheme returns all Indicators for given Theme', (done) ->
  themeAttributes = [{
    title: 'Theme 1'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) =>
    indicatorAttributes = [{
      title: "I'm an indicator of theme 1"
      theme: themes[0]._id
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    ).then( (subIndicators)->
      Theme.getIndicatorsByTheme(themes[0]._id, (err, returnedIndicators) ->
        if err?
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
