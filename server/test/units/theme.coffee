assert = require('chai').assert
helpers = require '../helpers'
Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
helpers = require '../helpers'
async = require('async')
_ = require('underscore')

suite('Theme')

test('.getFatThemes returns all the themes with their indicators populated', (done) ->
  themeAttributes = [{
    title: 'Theme 1'
    externalId: 1
  },{
    title: 'Theme 2'
    externalId: 2
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then((themes) ->
    indicatorAttributes = [{
      title: "I'm an indicator of theme 1"
      theme: themes[0].externalId
    },{
      title: "theme 2 indicator"
      theme: themes[1].externalId
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    ).then( (subIndicators)->
      Theme.getFatThemes((err, returnedThemes) ->
        if err
          console.error err
          throw new Error(err)

        assert.lengthOf returnedThemes, 2

        assert.strictEqual returnedThemes[0].title, themeAttributes[0].title
        assert.strictEqual returnedThemes[1].title, themeAttributes[1].title

        assert.lengthOf returnedThemes[0].indicators, 1
        assert.lengthOf returnedThemes[1].indicators, 1

        assert.strictEqual returnedThemes[0].indicators[0].title, indicatorAttributes[0].title
        assert.strictEqual returnedThemes[1].indicators[0].title, indicatorAttributes[1].title

        done()
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
  ).fail((err)->
    console.error err
    throw new Error(err)
  )
)

test('.getIndicatorsByTheme returns all Indicators for given Theme', (done) ->
  themeAttributes = [{
    title: 'Theme 1'
    externalId: 1
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) =>
    indicatorAttributes = [{
      title: "I'm an indicator of theme 1"
      theme: themes[0].externalId
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    ).then( (subIndicators)->
      Theme.getIndicatorsByTheme(themes[0].externalId, (err, returnedIndicators) ->
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
    externalId: 1
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) ->
    indicatorAttributes = [{
      title: "I'm an indicator of theme 1"
      theme: themes[0].externalId
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
