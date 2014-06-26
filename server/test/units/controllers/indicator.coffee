assert = require('chai').assert
helpers = require '../../helpers'
sinon = require('sinon')
Promise = require('bluebird')

IndicatorController = require('../../../controllers/indicators')
GDocIndicatorImporter = require('../../../lib/gdoc_indicator_importer')
Permissions = require('../../../lib/services/permissions')
AppConfig = require('../../../initializers/config')

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

test(".importGdoc calls GDocIndicatorImporter.import() with the given key
 but does not register for change callbacks if that feature is disabled", (done) ->
  key = '1234567'

  sandbox = sinon.sandbox.create()
  gdocImportStub = sandbox.stub(GDocIndicatorImporter, 'import', (key) ->
    Promise.resolve()
  )

  registerChangeCallbackSpy = sandbox.spy(
    GDocIndicatorImporter::, 'registerChangeCallback'
  )

  sandbox.stub(AppConfig, 'get', (key) ->
    if key is "features"
      return {} # no "auto_update_google_sheets"
  )

  fakeReq =
    path: '/indicators/import_gdoc'
    body:
      spreadsheetKey: key

  fakeRes =
    send: (code, body) ->
      try
        assert.strictEqual code, 201,
          "Expected response code to be 201"

        assert.strictEqual gdocImportStub.callCount, 1,
          "Expected GDocIndicatorImporter.import to be called once"

        assert.isTrue gdocImportStub.calledWith(key),
          "Expected GDocIndicatorImporter.import to be called with the given key"

        assert.strictEqual registerChangeCallbackSpy.callCount, 0,
          "Expected the application not to register a change callback"

        done()
      catch err
        done(err)
      finally
        sandbox.restore()

  IndicatorController.importGdoc(fakeReq, fakeRes)
  if gdocImportStub.restore? # Only restore if not restored already
    sandbox.restore()
)

test(".importGdoc calls GDocIndicatorImporter.import() registers for changes
 when the watch changes feature is enabled", (done) ->
  key = '1234567'

  sandbox = sinon.sandbox.create()
  gdocImportStub = sandbox.stub(
    GDocIndicatorImporter, 'import', Promise.resolve
  )

  registerChangeCallbackStub = sandbox.stub(
    GDocIndicatorImporter::, 'registerChangeCallback', Promise.resolve
  )

  sandbox.stub(AppConfig, 'get', (key) ->
    if key is "features"
      return {auto_update_google_sheets: true}
  )

  fakeReq =
    path: '/indicators/import_gdoc'
    body:
      spreadsheetKey: key

  fakeRes =
    send: (code, body) ->
      try
        assert.strictEqual code, 201,
          "Expected response code to be 201"

        assert.strictEqual registerChangeCallbackStub.callCount, 1,
          "Expected GDocIndicatorImporter.registerChangeCallback to be called"

        done()
      catch err
        done(err)
      finally
        sandbox.restore()

  IndicatorController.importGdoc(fakeReq, fakeRes)
)
