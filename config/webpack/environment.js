const {environment} = require('@rails/webpacker');
const webpack = require('webpack');
const path = require('path');

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: 'popper.js/dist/popper'
  })
);

environment.config.merge({
  resolve: {
    alias: {
      'jquery': path.join(__dirname, '../../node_modules/jquery/dist/jquery')
    },
  },
});

const erb = require('./loaders/erb');
environment.loaders.prepend('erb', erb);

module.exports = environment;

console.log('=== Environment ===');
console.log(JSON.stringify(environment, null, 2));
console.log('===================');
