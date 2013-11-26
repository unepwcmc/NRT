mongoose = require('mongoose')
mongoose.connect("mongodb://localhost/nrt_development")
IndicatorData = require('../../models/indicator_data').model
fs = require('fs')

console.log "Yo"
IndicatorData.dataToSeedJSON().then((json)->
  fs.writeFile("./lib/indicator_data.json", json, (err) ->
    if err
      console.error "Error writing indicator data backup:"
      console.error err
      console.error err.stack
    else
      console.log "Wrote indicator data to lib/indicator_data.json"
  )

).fail((err)->
  console.log "Error generating backup indicator data:"
  console.log err
  console.log err.stack
)
