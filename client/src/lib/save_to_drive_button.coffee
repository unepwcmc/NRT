extractFilenameFromAddress = (address)->
  chunks = address.split('/')
  chunks[chunks.length - 1]

class window.SaveToDriveButton
  constructor: (@el, fileAddress) ->

    options =
      src: fileAddress
      filename: extractFilenameFromAddress(fileAddress)
      sitename: "National Reporting Toolkit"

    gapi.savetodrive.render(@el, options)
