console.log "Starting deploy"
CommandRunner = require('./command-runner')

process.exit() if process.env.NODE_ENV is "test"

PARENT_DIR = "#{process.cwd()}/../"

console.log "Switching to #{PARENT_DIR}"
process.chdir(PARENT_DIR)
console.log "Pulling code"
git_pull = CommandRunner.spawn('git', ['pull', 'origin', 'deploy'])

git_pull.on('close', (code) ->
  console.log "Code pulled"
  if code == 0
    process.chdir('client/')
    console.log "npm installing in client"
    npm_install = CommandRunner.spawn('npm', ['install'])

    npm_install.on('close', (code) ->
      console.log "client npm installed"
      if code == 0
        console.log "running grunt"
        grunt = CommandRunner.spawn('grunt')
        grunt.on('close', (code) ->
          console.log "grunt run"
          if code == 0
            process.chdir('../')
            process.chdir('server/')

            console.log "Installing server"
            npm_install = CommandRunner.spawn('npm', ['install'])
            npm_install.on('close', (code) ->
              console.log "Server installed, done"
              process.exit()
            )
        )
    )
)
