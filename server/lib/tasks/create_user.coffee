require('../../initializers/config').initialize()
require('../../initializers/mongo')()

User = require('../../models/user').model
readline = require 'readline'

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
  terminal: false
)

console.log "## Create user ##"
console.log "Enter name:"

rl.once('line', (name)->
  console.log "Enter email:"

  rl.once('line', (email)->
    console.log "Enter a password:"

    rl.once('line', (password)->
      console.log "Creating user..."
      user = new User(
        name: name
        email: email
        password: password
      )

      user.save (err, user) ->
        if err?
          console.error "Error creating user:"
          console.error err
        else
          console.log "Created user #{email}"

        process.exit()
    )
  )
)
