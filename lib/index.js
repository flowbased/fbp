const parser = require('./fbp');
const serialize = require('./serialize');

module.exports = {
  SyntaxError: parser.SyntaxError,
  parse: parser.parse,
  serialize,
};
