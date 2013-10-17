assert = require('chai').assert
helpers = require '../helpers'
Q = require('q')
User = require('../../models/user').model

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

test(".isValidPassword checks if bcrypt(password)
  matches stored password", (done) ->
  user = new User(password: "password")

  user.save( (err, savedUser) ->
    if err?
      console.error err
      throw new Error(err)

    savedUser
      .isValidPassword('password')
      .then( (isValid) ->

        assert.isTrue(
          isValid,
          "Expected password 'password' for user to be valid"
        )

        savedUser.isValidPassword('hats')
      ).then( (isValid) ->

        assert.isFalse(
          isValid
          "Expected password 'hats' for user to be invalid"
        )

        done()
      )
  )
)

test(".save hashes the user's password before saving", (done) ->
  user = new User(password: "password")

  user.save( (err, savedUser) ->
    if err?
      throw new Error(err)

    assert.notStrictEqual(
      "password",
      savedUser.password,
      "Expected User's saved password to not match the plaintext"
    )

    done()
  )
)
