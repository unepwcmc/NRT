suite("Google Drive importer")

test(".constructor builds a DOM element google drive button", ->
  window.gapi =
    savetodrive:
      render: sinon.spy()

  link = "//some/file.xlsx"
  el = $("<span>")[0]
  button = new SaveToDriveButton(el, link)

  assert.isTrue(gapi.savetodrive.render.calledOnce,
    "Expected the google API for save to drive to be called")

  renderCallArgs = gapi.savetodrive.render.getCall(0).args

  assert.strictEqual renderCallArgs[0], el,
    "Expected the google API to be passed the button element"

  expectedButtonOptions =
    src: link
    filename: "file.xlsx"
    sitename: "National Reporting Toolkit"

  assert.deepEqual(
    renderCallArgs[1], expectedButtonOptions,
    "Expected the google API to be passed the correct options"
  )
)

test(".onSuccess calls the given callback when a
.save-to-drive-save-complete-filename object appears")
