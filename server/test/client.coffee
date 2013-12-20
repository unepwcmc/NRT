page = require('webpage').create()

page.open('http://localhost:3000/tests', (status) ->
  if status == 'fail'
    return phantom.exit(1)

  setTimeout( ->
    failureCount = page.evaluate( () ->
      return document.querySelector('.failures em').innerText
    )

    console.log("NUMBER OF FAILURES: #{failureCount}")

    if failureCount > 0
      phantom.exit(1)

    page.close()
    phantom.exit(0)
  , 2000)
)
