assert = require('chai').assert
helpers = require '../helpers'
sinon = require('sinon')

IndicatorController = require('../../controllers/indicators')
Permissions = require('../../lib/services/permissions')

suite('Indicator Controller')

test(".show redirects back if trying to create a draft
  when Permissions::canEdit returns false", (done) ->

  canEditStub = sinon.stub(Permissions::, 'canEdit', ->
    return false
  )

  fakeReq =
    path: '/indicators/432523/draft'

  fakeRes =
    redirect: (action) ->
      try
        assert.strictEqual action, "back",
          "Expected to be redirected back"

        done()
      catch err
        done(err)
      finally
        canEditStub.restore()

  IndicatorController.show(fakeReq, fakeRes)
  canEditStub.restore()
)

test(".publishDraft redirects back if Permissions::canEdit
  returns false", (done) ->

  canEditStub = sinon.stub(Permissions::, 'canEdit', ->
    return false
  )

  fakeReq =
    path: '/indicators/432523/draft'

  fakeRes =
    redirect: (action) ->
      try
        assert.strictEqual action, "back",
          "Expected to be redirected back"

        done()
      catch err
        done(err)
      finally
        canEditStub.restore()

  IndicatorController.publishDraft(fakeReq, fakeRes)
  canEditStub.restore()
)
