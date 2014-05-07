assert = require('chai').assert
hbs = require('express-hbs')
sinon = require('sinon')

Permissions = require('../../lib/services/permissions')

suite('Handlebars helpers')

test('#ifCanEdit calls options.fn if Permissions(currentUser).canEdit
  returns true', ->

  canEditStub = sinon.stub(Permissions::, 'canEdit', ->
    return true
  )

  options =
    fn: sinon.spy()

  hbs.handlebars.helpers.ifCanEdit(null, options)

  try
    assert.strictEqual options.fn.callCount, 1,
      "Expected options.fn to be called once"
  finally
    canEditStub.restore()
)

test("#ifCanEdit doesn't call options.fn if Permissions(currentUser).canEdit
  returns false", ->

  canEditStub = sinon.stub(Permissions::, 'canEdit', ->
    return false
  )

  options =
    fn: sinon.spy()

  hbs.handlebars.helpers.ifCanEdit(null, options)

  try
    assert.strictEqual options.fn.callCount, 0,
      "Expected options.fn not to be called"
  finally
    canEditStub.restore()
)
