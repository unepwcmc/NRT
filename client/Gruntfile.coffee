module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    clean:
      options:
        force: true
      dist: ['dist/', '../server/public']

    coffee:
      source:
        src: 'dist/js/application.coffee'
        dest: 'dist/js/application.js'
        ext: '.js'
      test:
        src: 'test/tests.coffee'
        dest: 'test/tests.js'
        ext: '.js'

    concat:
      source:
        src: grunt.file.readJSON('src/compile_manifest.json')
        dest: 'dist/js/application.coffee'
      dist:
        src: ['dist/js/templates.js', 'dist/js/application.js']
        dest: 'dist/js/application.js'
      test:
        src: ['test/src/**/*.coffee']
        dest: 'test/tests.coffee'

    handlebars:
      source:
        files:
          'dist/js/templates.js': ['src/templates/*.hbs']
        options:
          namespace: 'Handlebars.templates'
          processName: (filename) ->
            filename.replace(/^src\/templates\//, '')

    copy:
      dist:
        files: [
          expand: true
          cwd: 'src/images/'
          dest: 'dist/images'
          src: '**/*'
        ,
          expand: true
          cwd: 'src/vendor/'
          dest: 'dist/'
          src: ['**/*']
        ]
      release:
        files: [
          expand: true
          cwd: 'dist/'
          dest: '../server/public'
          src: ['**/*']
        ,
          expand: true
          cwd: 'test/'
          dest: '../server/public/js'
          src: 'tests.js'
        ]

    sass:
      dist:
        files:
          'dist/css/main.css': 'src/sass/main.scss'

    watch:
      files: ['src/**/*', 'test/**/*'],
      tasks: 'default'
  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-handlebars')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-sass')

  grunt.registerTask('build', ['clean', 'concat:source', 'coffee:source', 'handlebars', 'concat:dist', 'sass', 'concat:test', 'coffee:test', 'copy:dist', 'copy:release'])
  grunt.registerTask('default', ['build', 'watch'])
