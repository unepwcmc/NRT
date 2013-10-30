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

test('.save with a distinguishedName', (done) ->
  dn = "CN=The Queen,OU=Royalty"
  user = new User(distinguishedName: dn)

  user.save( (err, savedUser) ->
    if err?
      console.error err
      throw new Error(err)

    assert.strictEqual(
      dn,
      savedUser.distinguishedName,
      "Expected user to have a distinguished name"
    )

    done()
  )
)

test(".isLDAPAccount should return true if the account has a distinguished name", ->
  user = new User(distinguishedName: "CN=The Queen,OU=Royalty")
  assert.isTrue user.isLDAPAccount()
)

test(".isLDAPAccount should return false if the account does not have a
  distinguished name", ->
  user = new User(distinguishedName: "CN=The Queen,OU=Royalty")
  assert.isTrue user.isLDAPAccount()
)

test(".loginFromLocalDb succeeds if the user's password is correct", (done) ->
  helpers.createUser(
    email: "hats"
    password: "boats"
  ).then( (user) ->
    authenticationCallback = (err, user) ->
      assert.ok user, "Expected user to be returned when authentication successful"
      assert.strictEqual "hats", user.email

      done()

    user.loginFromLocalDb("boats", authenticationCallback)
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

    user.loginFromLocalDb("ships", callback)
  ).fail( (err) ->
    console.error err
    throw err
  )
)

test("Usernames must be unique", (done) ->
  helpers.createUser().then( (user) ->
    helpers.createUser()
  ).then( (user) ->

    assert.isUndefined user, "Expected duplicate user creation to fail"
    done()

  ).fail( (err) ->

    console.error err
    assert.match err, /duplicate key error index/
    done()

  )
)
