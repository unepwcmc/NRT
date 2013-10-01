suite('User Collection')

test('.search when collection is empty triggers a fetch', ->
  users = new Backbone.Collections.UserCollection()

  fetchStub = sinon.stub(users, 'fetch')

  users.search('hat')

  assert.ok(
    fetchStub.calledOnce,
    "Expected users.fetch to be called once but was called #{fetchStub.callCount} times"
  )
)

test(".search when collection is not empty it doesn't trigger a fetch", ->
  users = new Backbone.Collections.UserCollection([{}])

  fetchStub = sinon.stub(users, 'fetch')

  users.search('hat')

  assert.notOk(
    fetchStub.calledOnce,
    "Expected users.fetch not to be called but was called #{fetchStub.callCount} times"
  )
)

test(".search
  when given a search term with a partial match with incorrect case for one user email,
  it returns only that user", (done) ->
  users = new Backbone.Collections.UserCollection([
    {email: 'hats'},
    {email: 'boats'}
  ])

  users.search('oAt').done((results) ->
    assert.lengthOf results, 1
    assert.strictEqual results[0].get('email'), 'boats'
    done()
  ).fail((err) ->
    console.log err
    throw err
  )
)
test(".search
  when the collection has some users populated
  when given a search term with a partial match with incorrect case for one user email,
  it returns only that user", (done) ->
  users = new Backbone.Collections.UserCollection([
    {email: 'hats'},
    {email: 'boats'}
  ])

  users.search('oAt').done((results) ->
    assert.lengthOf results, 1
    assert.strictEqual results[0].get('email'), 'boats'
    done()
  ).fail((err) ->
    console.log err
    throw err
  )
)

test(".search
  when the collection has no users populated
  when given a search term it queries the server and returns the correct results" , (done) ->
  users = new Backbone.Collections.UserCollection()

  fetchStub = sinon.stub(users, 'fetch', (options)->
    users.set([
      {email: 'bear'},
      {email: 'best'}
    ])
    options.success()
  )

  users.search('est').done((results) ->
    assert.lengthOf results, 1
    assert.strictEqual results[0].get('email'), 'best'
    done()
  ).fail((err) ->
    console.log err
    throw err
  )
)
