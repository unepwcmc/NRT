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

test(".search on a pre-populated collection returns matching users,
  regardless of case", (done) ->
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

test(".search on an un-populated collection 
  returns matching results" , (done) ->
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
