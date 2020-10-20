/* eslint-disable */
if (typeof global !== 'undefined') {
  // Node.js injections for Mocha tests
  global.chai = require('chai');
  global.parser = require('../../lib/index');
} else {
  // Browser injections for Mocha tests
  window.parser = require('fbp');
}
