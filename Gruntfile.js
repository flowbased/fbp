module.exports = function () {
  // Project configuration
  this.initConfig({
    pkg: this.file.readJSON('package.json'),

    // Generate library from Peg grammar
    peg: {
      fbp: {
        src: 'grammar/fbp.peg',
        dest: 'lib/fbp.js',
      },
    },

    yaml: {
      schemas: {
        files: [{
          expand: true,
          cwd: 'schemata/',
          src: '*.yaml',
          dest: 'schema/',
        },
        ],
      },
    },

    // Build the browser Component
    noflo_browser: {
      build: {
        files: {
          'browser/fbp.js': ['browser/entry.js'],
        },
        options: {
          manifest: {
            runtimes: ['noflo'],
            discover: true,
            recursive: true,
            silent: true,
          },
        },
      },
    },

    // Automated recompilation and testing when developing
    watch: {
      files: ['spec/*.js', 'grammar/*.peg'],
      tasks: ['test'],
    },

    // BDD tests on Node.js
    mochaTest: {
      nodejs: {
        src: ['spec/*.js'],
        options: {
          reporter: 'spec',
        },
      },
    },

    // BDD tests on browser
    karma: {
      unit: {
        configFile: 'karma.config.js',
      },
    },
  });

  // Grunt plugins used for building
  this.loadNpmTasks('grunt-yaml');
  this.loadNpmTasks('grunt-peg');
  this.loadNpmTasks('grunt-noflo-browser');

  // Grunt plugins used for testing
  this.loadNpmTasks('grunt-mocha-test');
  this.loadNpmTasks('grunt-karma');
  this.loadNpmTasks('grunt-contrib-watch');

  this.registerTask('build', ['peg', 'yaml', 'noflo_browser']);
  this.registerTask('test', ['build', 'mochaTest', 'karma']);
  this.registerTask('default', ['build']);
};
