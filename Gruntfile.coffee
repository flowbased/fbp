module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    peg:
      fbp:
        grammar: 'grammar/fbp.peg'
        outputFile: 'lib/fbp.js'

  @loadNpmTasks 'grunt-peg'

  @registerTask 'build', ['peg']
  @registerTask 'test', ['build']
  @registerTask 'default', ['build']
