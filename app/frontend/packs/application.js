/* eslint no-console:0 */

const images = require.context('../images', true);

import '../stylesheets/application.scss'
import Routes from '../javascripts/js-routes.js.erb'

window.Routes = Routes;
