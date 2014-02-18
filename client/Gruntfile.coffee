module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    clean:
      options:
        force: true
      ephemeral: [
        'src/templates/templates.js',
        'test/tests.js'
      ]
      all: [
        '../server/public/css',
        '../server/public/font',
        '../server/public/images',
        '../server/public/js',
        '../server/public/lib'
      ]

    coffee:
      source:
        src: '../server/public/js/application.coffee'
        dest: '../server/public/js/application.js'
        ext: '.js'
      test:
        src: 'test/tests.coffee'
        dest: 'test/tests.js'
        ext: '.js'

    concat:
      source:
        src: grunt.file.readJSON('src/compile_manifest.json')
        dest: '../server/public/js/application.coffee'
      test:
        src: ['test/src/helpers.coffee', 'test/src/**/*.coffee']
        dest: 'test/tests.coffee'

    handlebars:
      source:
        files:
          'src/templates/templates.js': ['src/templates/**/*.hbs']
        options:
          namespace: 'Handlebars.templates'
          processName: (filename) ->
            filename.replace(/^src\/templates\//, '')

    copy:
      libs:
        files: [
          expand: true
          cwd: 'src/images/'
          dest: '../server/public/images'
          src: '**/*'
        ,
          expand: true
          cwd: 'src/vendor/'
          dest: '../server/public/'
          src: ['**/*']
        ]
      test:
        files: [
          expand: true
          cwd: 'test/'
          dest: '../server/public/js'
          src: 'tests.js'
        ]
      templates:
        files: [
          expand: true
          cwd: 'src/templates/'
          src: 'templates.js'
          dest: '../server/public/js'
        ]

    sass:
      dist:
        files:
          '../server/public/css/main.css': 'src/css/main.scss'
          '../server/public/css/report.css': 'src/css/report.scss'
          '../server/public/css/dashboard.css': 'src/css/dashboard.scss'
          '../server/public/css/about.css': 'src/css/about.scss'
          '../server/public/css/indicator.css': 'src/css/indicator.scss'
          '../server/public/css/theme.css': 'src/css/theme.scss'
          '../server/public/css/login.css': 'src/css/login.scss'
          '../server/public/css/rtl_overrides.css': 'src/css/rtl_overrides.scss'

    watch:
      source:
        files: ['src/**/*.coffee']
        tasks: 'concat:source'
      templates:
        files: ['src/**/*.hbs']
        tasks: 'templates'
      tests:
        files: ['test/src/**/*.coffee']
        tasks: 'tests'

    mocha:
      test:
        options:
          urls: ['http://localhost:3000/tests']
  )

  grunt.loadNpmTasks('grunt-contrib-handlebars')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-mocha')
  grunt.loadNpmTasks('grunt-sass')

  grunt.registerTask('templates', ['handlebars', 'copy:templates'])
  grunt.registerTask('source', ['concat:source', 'coffee:source'])
  grunt.registerTask('tests', ['concat:test', 'coffee:test', 'copy:test'])

  grunt.registerTask('default', ['templates', 'source', 'tests', 'sass',
    'copy:libs', 'copy:test', 'clean:ephemeral'])
