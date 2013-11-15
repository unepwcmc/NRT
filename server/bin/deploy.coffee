CommandRunner = require('./command-runner')

process.exit() if process.env.NODE_ENV is "test"

PARENT_DIR = "#{process.cwd()}/../"

process.chdir(PARENT_DIR)
git_pull = CommandRunner.spawn('git', ['pull', 'origin', 'deploy'])

git_pull.on('close', (code) ->
  if code == 0
    process.chdir('client/')
    npm_install = CommandRunner.spawn('npm', ['install'])

    npm_install.on('close', (code) ->
      if code == 0
        grunt = CommandRunner.spawn('grunt')
        grunt.on('close', (code) ->
          if code == 0
            process.chdir('../')
            process.chdir('server/')

            npm_install = CommandRunner.spawn('npm', ['install'])
            npm_install.on('close', (code) ->
              process.exit()
            )
        )
    )
)
