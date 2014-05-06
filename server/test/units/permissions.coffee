assert = require('chai').assert
sinon = require('sinon')

AppConfig = require('../../initializers/config')
Permissions = require('../../lib/services/permissions')
User = require('../../models/user').model

suite('Permissions')

test(".getEdit returns true if the 'open_access' feature is enabled", ->
  configStub = sinon.stub(AppConfig, 'get', (key) ->
    if key is 'features'
      return open_access: true
  )

  try
    assert.isTrue (new Permissions()).canEdit(),
      "Expected getEdit to return true"
  finally
    configStub.restore()
)

test(".getEdit returns false if no user is specified and 'open_access'
is disabled", ->

  configStub = sinon.stub(AppConfig, 'get', (key) ->
    if key is 'features'
      return open_access: false
  )

  try
    assert.isFalse (new Permissions()).canEdit(),
      "Expected getEdit to return false"
  finally
    configStub.restore()
)

test(".getEdit returns true if a user is specified", ->

  configStub = sinon.stub(AppConfig, 'get', (key) ->
    if key is 'features'
      return open_access: false
  )

  try
    permissions = new Permissions(new User().toJSON())
    assert.isTrue permissions.canEdit(),
      "Expected getEdit to return true"
  finally
    configStub.restore()
)
