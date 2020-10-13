var parser = require('./fbp');
var serialize = require('./serialize');

module.exports = {
  SyntaxError: parser.SyntaxError,
  parse: parser.parse,
  serialize: serialize,
};
