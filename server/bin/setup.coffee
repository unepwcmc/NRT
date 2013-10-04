spawn = require('child_process').spawn

process.exit() if process.env.NODE_ENV is "test"

PARENT_DIR = "#{process.cwd()}/../"

process.chdir(PARENT_DIR)
git_pull = spawn('git', ['pull', 'origin', 'auto-deploy'])

git.on('close', (code) ->
  if code == 0
    process.chdir('client/')
    npm_install = spawn('npm', ['install'])

    npm_install.on('close', (code) ->
      if code == 0
        grunt = spawn('grunt')
        grunt.on('close', (code) ->
          if code == 0
            process.chdir('../')
            process.chdir('server/')

            npm_install = spawn('npm', ['install'])
            npm_install.on('close', (code) ->
              process.exit()
            )
        )
    )
)
