module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    peg:
      fbp:
        grammar: 'grammar/fbp.peg'
        outputFile: 'lib/fbp.js'

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'grammar/*.peg']
      tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']

  @loadNpmTasks 'grunt-peg'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['peg']
  @registerTask 'test', ['build', 'cafemocha']
  @registerTask 'default', ['build']
