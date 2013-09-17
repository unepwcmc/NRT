assert = require('chai').assert
helpers = require '../helpers'
Theme = require('../../models/theme').model
helpers = require '../helpers'
async = require('async')
_ = require('underscore')

suite('Theme')



test('.getFatThemes returns all the themes with their indicators populated', (done) ->
  themeAttributes = [{
    title: 'Theme 1'
  },{
    title: 'Theme 2'
  }]

  helpers.createThemesFromAttributes(themeAttributes, (err, themes) ->
    if err
      console.error err
      throw new Error(err)
    
    
    indicatorAttributes = [{
      title: "I'm an indicator of theme 1"
      theme_id: themes[0]._id
    },{
      title: "theme 2 indicator"
      theme_id: themes[1]._id
    }]

    helpers.createIndicatorModels(theme1SubIndicatorAttributes).done((subIndicators)->
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
        assert.strictEqual returnedThemes[1].indicators[1].title, indicatorAttributes[1].title
      )
    )
  )

)
