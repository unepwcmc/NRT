path = require('path')

require('../../initializers/config').initialize()
require('../../initializers/mongo')()

IndicatorData = require('../../models/indicator_data').model
fs = require('fs')

console.log "Backing up Indicator Data"
IndicatorData.dataToSeedJSON().then((json)->
  dataFilename = path.join(process.cwd(), 'config', 'seeds', 'indicator_data.json')

  fs.writeFile(dataFilename, json, (err) ->
    if err
      console.error "Error writing indicator data backup:"
      console.error err
      console.error err.stack
      process.exit(1)
    else
      console.log "Wrote indicator data to #{dataFilename}"
      process.exit(0)
  )

).fail((err)->
  console.log "Error generating backup indicator data:"
  console.log err
  console.log err.stack
)
