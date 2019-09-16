const {environment} = require('@rails/webpacker');
const webpack = require('webpack');

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/dist/jquery',
    jQuery: 'jquery/dist/jquery',
    Popper: 'popper.js/dist/popper'
  })
);

// To enable jQuery for $ in browser console
environment.loaders.append('expose', {
  test: require.resolve('jquery'),
  use: [{
    loader: 'expose-loader',
    options: '$'
  }]
});

const erb = require('./loaders/erb');
environment.loaders.prepend('erb', erb);

module.exports = environment;

console.log('=== Environment ===');
console.log(JSON.stringify(environment, null, 2));
console.log('===================');
