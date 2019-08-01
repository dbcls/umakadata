const { environment } = require('@rails/webpacker');

const erb = require('./loaders/erb');
environment.loaders.prepend('erb', erb);

module.exports = environment;

console.log('=== Environment ===');
console.log(JSON.stringify(environment, null, 2));
console.log('===================');
