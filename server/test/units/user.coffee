assert = require('chai').assert
helpers = require '../helpers'
Q = require('q')

suite('User')

test('.canEdit resolves when given a page whose parent is owned by the user', (done) ->
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
    theOwner.canEdit(page).then(->
      done()
    ).fail( (err) ->
      console.error err
      throw new Error("Expected user to be able to edit page")
    )

  ).fail((err) ->
    console.error err
    throw err
  )
)
