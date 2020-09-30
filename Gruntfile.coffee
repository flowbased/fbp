module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Generate library from Peg grammar
    peg:
      fbp:
        src: 'grammar/fbp.peg'
        dest: 'lib/fbp.js'

    yaml:
      schemas:
        files: [
          expand: true
          cwd: 'schemata/'
          src: '*.yaml'
          dest: 'schema/'
        ]

    # Build the browser Component
    noflo_browser:
      build:
        files:
          'browser/fbp.js': ['browser/entry.js']
        options:
          manifest:
            runtimes: ['noflo']
            discover: true
            recursive: true
            silent: true

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'grammar/*.peg']
      tasks: ['test']

    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

    # BDD tests on browser
    karma:
      unit:
        configFile: 'karma.config.js'

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

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-yaml'
  @loadNpmTasks 'grunt-peg'
  @loadNpmTasks 'grunt-noflo-browser'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-karma'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['peg', 'yaml', 'noflo_browser']
  @registerTask 'test', ['build', 'coffee', 'mochaTest', 'karma']
  @registerTask 'default', ['build']
