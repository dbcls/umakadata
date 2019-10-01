/* eslint no-console:0 */

import Routes from '../javascripts/js-routes.js.erb'
import '../stylesheets/application'

const images = require.context('../images', true);

window.Routes = Routes;
