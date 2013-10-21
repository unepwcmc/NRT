assert = require('chai').assert
helpers = require '../helpers'
Q = require('q')
User = require('../../models/user').model

suite('User')

test('Password salt values can be stored on user', (done) ->
  user = new User(salt: 'sodiumchloride')
  user.save( (err, theUser) ->
    if err?
      console.error err
      throw new Error(err)

    assert.strictEqual(
      theUser.salt,
      'sodiumchloride',
      "Expected user's salt to be sodiumchloride"
    )

    done()
  )
)

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
      console.error err
      throw new Error(err)

    assert.notStrictEqual(
      "password",
      savedUser.password,
      "Expected User's saved password to not match the plaintext"
    )

    done()
  )
)

test(".isLDAPAccount should return true if the email supplied is @ead.ae", ->
  assert.isTrue User.isLDAPAccount("kanye@ead.ae")
)

test(".isLDAPAccount should return true if the email is @subdomain.ead.ae", ->
  assert.isTrue User.isLDAPAccount("kanye@subdomain.ead.ae")
)

test(".isLDAPAccount should return false if the email contains @ead.ae", ->
  assert.isFalse User.isLDAPAccount("gob@bead.ae")
)

test(".isLDAPAccount should return false if the email supplied is not @ead.ae", ->
  assert.isFalse User.isLDAPAccount("michael@bluth-company.com")
)

test('.loginFromLocalDb fails if the user does not exist', (done) ->
  authenticationCallback = (err, user) ->
    assert.notOk user, "Expected returned user to be empty"

    done()

  User.loginFromLocalDb("hats", "boats", authenticationCallback)
)

test(".loginFromLocalDb succeeds if the user's password is correct", (done) ->
  helpers.createUser(
    email: "hats"
    password: "boats"
  ).then( (user) ->
    callbackSpy = (err, user) ->
      assert.ok user, "Expected user to be returned when authentication successful"
      assert.strictEqual "hats", user.email

      done()

    User.loginFromLocalDb("hats", "boats", callbackSpy)
  ).fail( (err) ->
    console.error err
    throw err
  )
)

test(".loginFromLocalDb fails if the user's password is incorrect", (done) ->
  helpers.createUser(
    email: "hats"
    password: "boats"
  ).then( (user) ->
    callback = (err, user) ->
      assert.notOk user, "Expected user to not be returned when authentication fails"

      done()

    User.loginFromLocalDb("hats", "ships", callback)
  ).fail( (err) ->
    console.error err
    throw err
  )
)
