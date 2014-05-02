GDocIndicatorImporter = require '../gdoc_indicator_importer'
readline = require('readline')

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
  terminal: false
)

console.log "What is your GDoc spreadsheet key?"

rl.once('line', (key) ->
  console.log "OK, importing #{key}"

  GDocIndicatorImporter.import(key).then(->
    console.log "Successfully imported"
  ).catch((err)->
    console.log "Uh oh, something went wrong"
    console.log err.stack
  ).finally(process.exit)

)
