module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Generate library from Peg grammar
    peg:
      fbp:
        src: 'grammar/fbp.peg'
        dest: 'lib/fbp.js'

    # Build the browser Component
    noflo_browser:
      build:
        files:
          'browser/fbp.js': ['component.json']

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'grammar/*.peg']
      tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-peg'
  @loadNpmTasks 'grunt-noflo-browser'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['peg', 'noflo_browser']
  @registerTask 'test', ['build', 'coffee', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
