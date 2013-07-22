module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    clean:
      folder: ['public/clientApp/test/js/']

    coffee:
      test:
        expand: true
        cwd: 'test'
        src: '**/*.coffee'
        dest: 'public/test/js/src'
        ext: '.js'

    concat:
      tests:
        src: 'public/test/js/src/**/*.js'
        dest: 'public/test/js/tests.js'

    shell:
      makeDir:
        command: 'cd public/clientApp && diorama compile'

    watch:
      files: ['public/**/*.coffee'],
      tasks: 'default'
  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-shell')

  grunt.registerTask('default', ['clean', 'coffee', 'shell', 'concat'])

